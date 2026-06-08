import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/data_cache_policy.dart';
import '../../../../core/cache/hive_local_cache.dart';
import '../../../../core/data/restaurant_filter_store.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../domain/entities/restaurant_page_entity.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._homeRepository,
    this._catalogRepository,
    this._filterStore,
    this._hiveCache,
  ) : super(
          HomeState(
            sortOption: _filterStore.sortOption,
            priceOption: _filterStore.priceOption,
            cuisineFilterIds: _filterStore.cuisineIds,
          ),
        );

  final HomeRepository _homeRepository;
  final CatalogRepository _catalogRepository;
  final RestaurantFilterStore _filterStore;
  final HiveLocalCache _hiveCache;
  final _cache = DataCachePolicy();
  var _loadGeneration = 0;

  /// Memory + Hive disk cache, then API if stale.
  Future<void> loadHomeIfNeeded() async {
    await _restoreFromDisk();
    await loadHome();
  }

  Future<void> _restoreFromDisk() async {
    if (state.restaurants.isNotEmpty) return;
    final cached = _hiveCache.readHome(state);
    if (cached == null) return;
    emit(cached);
    _cache.markFresh();
  }

  /// P1: restaurants (show list). P2: banners, sliders, cuisines (background).
  Future<void> loadHome({bool force = false}) async {
    final generation = ++_loadGeneration;

    if (!force &&
        state.status == HomeStatus.loaded &&
        state.restaurants.isNotEmpty &&
        _cache.isFresh) {
      unawaited(_loadSecondaryContent(generation));
      return;
    }

    final hadRestaurants = state.restaurants.isNotEmpty;
    if (!hadRestaurants) {
      emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    }

    final restaurantsResult = await _fetchRestaurantsWithRetry(page: 1);

    if (isClosed || generation != _loadGeneration) return;

    if (restaurantsResult.isFailure) {
      if (hadRestaurants) {
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            errorMessage: restaurantsResult.failure?.message,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: restaurantsResult.failure?.message,
        ),
      );
      return;
    }

    final page = restaurantsResult.data!;
    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        restaurants: page.restaurants,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        isStoreAvailable: page.isStoreAvailable,
        cityImage: page.cityImage,
        emptyMessage: page.emptyMessage,
        openRestaurantCount: page.restaurants.where((r) => r.isOpen).length,
        clearError: true,
      ),
    );
    _cache.markFresh();
    unawaited(_hiveCache.saveHome(state));

    unawaited(_loadSecondaryContent(generation));
  }

  Future<void> invalidateCache() async {
    _cache.invalidate();
    await _hiveCache.clearHomeForCurrentLocation();
  }

  Future<void> _loadSecondaryContent(int generation) async {
    final results = await Future.wait([
      _homeRepository.loadHomeFeed(),
      _catalogRepository.getCuisines(),
    ]);

    if (isClosed || generation != _loadGeneration) return;

    final feedResult = results[0] as Result<HomeFeedEntity>;
    final cuisinesResult = results[1] as Result<List<CuisineEntity>>;

    HomeFeedEntity? feed;
    if (feedResult.isSuccess) {
      feed = feedResult.data;
    }

    final cuisines =
        cuisinesResult.isSuccess ? (cuisinesResult.data ?? <CuisineEntity>[]) : null;

    if (feed == null && cuisines == null) return;

    emit(
      state.copyWith(
        notificationMessage: feed?.notificationMessage,
        couponBanners: feed?.couponBanners ?? state.couponBanners,
        sliders: feed?.sliders ?? state.sliders,
        customerCarePhone: feed?.customerCare?.phone ?? state.customerCarePhone,
        customerCareWhatsapp:
            feed?.customerCare?.whatsapp ?? state.customerCareWhatsapp,
        cuisines: cuisines ?? state.cuisines,
      ),
    );
    unawaited(_hiveCache.saveHome(state));
  }

  Future<Result<RestaurantPageEntity>> _fetchRestaurantsWithRetry({
    required int page,
    RestaurantFoodFilter? foodFilter,
    int maxAttempts = 2,
  }) async {
    Result<RestaurantPageEntity>? last;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (isClosed) break;
      }
      last = await _fetchRestaurants(page: page, foodFilter: foodFilter);
      if (last.isSuccess) return last;
    }
    return last ?? Result.failure(const NetworkFailure());
  }

  Future<void> refresh() async {
    await invalidateCache();
    await loadHome(force: true);
  }

  Future<void> setFoodFilter(RestaurantFoodFilter filter) async {
    if (state.foodFilter == filter) {
      await _reloadRestaurants(filter: RestaurantFoodFilter.all);
      return;
    }
    await _reloadRestaurants(filter: filter);
  }

  /// After Android `FilterFragment` Save / Reset.
  Future<void> applyStoredFilters() async {
    emit(
      state.copyWith(
        sortOption: _filterStore.sortOption,
        priceOption: _filterStore.priceOption,
        cuisineFilterIds: _filterStore.cuisineIds,
        clearSortOption: _filterStore.sortOption == null,
        clearPriceOption: _filterStore.priceOption == null,
        clearCuisineFilterIds: _filterStore.cuisineIds.isEmpty,
      ),
    );
    await _reloadRestaurants(filter: state.foodFilter);
  }

  Future<void> _reloadRestaurants({required RestaurantFoodFilter filter}) async {
    emit(
      state.copyWith(
        foodFilter: filter,
        isReloadingRestaurants: true,
        clearError: true,
      ),
    );

    final result = await _fetchRestaurants(page: 1, foodFilter: filter);

    if (isClosed) return;

    if (result.isFailure) {
      emit(
        state.copyWith(
          isReloadingRestaurants: false,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }

    final page = result.data!;
    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        restaurants: page.restaurants,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        isStoreAvailable: page.isStoreAvailable,
        cityImage: page.cityImage,
        emptyMessage: page.emptyMessage,
        openRestaurantCount:
            page.restaurants.where((r) => r.isOpen).length,
        isReloadingRestaurants: false,
        clearError: true,
      ),
    );
    await _hiveCache.saveHome(state);
  }

  Future<void> loadMoreRestaurants() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _fetchRestaurants(page: nextPage);

    if (result.isFailure) {
      emit(state.copyWith(isLoadingMore: false));
      return;
    }

    final page = result.data!;
    final merged = [...state.restaurants, ...page.restaurants];

    emit(
      state.copyWith(
        restaurants: merged,
        currentPage: nextPage,
        totalPages: page.totalPages,
        isLoadingMore: false,
        openRestaurantCount: merged.where((r) => r.isOpen).length,
      ),
    );
    await _hiveCache.saveHome(state);
  }

  Future<Result<RestaurantPageEntity>> _fetchRestaurants({
    required int page,
    RestaurantFoodFilter? foodFilter,
  }) {
    return _catalogRepository.getRestaurants(
      page: page,
      foodFilter: foodFilter ?? state.foodFilter,
      cuisineIds: state.cuisineFilterIds,
      sortOption: state.sortOption,
      priceOption: state.priceOption,
    );
  }
}
