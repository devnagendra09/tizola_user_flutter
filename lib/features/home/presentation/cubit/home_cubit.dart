import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/data_cache_policy.dart';
import '../../../../core/cache/hive_local_cache.dart';
import '../../../../core/data/restaurant_filter_store.dart';
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

  Future<void> loadHome({bool force = false}) async {
    if (!force &&
        state.status == HomeStatus.loaded &&
        state.restaurants.isNotEmpty &&
        _cache.isFresh) {
      return;
    }

    final showBlockingLoader = state.restaurants.isEmpty;
    if (showBlockingLoader) {
      emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    }

    _mergeHomeFeed();

    final results = await Future.wait([
      _catalogRepository.getCuisines(),
      _fetchRestaurants(page: 1),
    ]);

    if (isClosed) return;

    final cuisinesResult = results[0] as Result<List<CuisineEntity>>;
    final restaurantsResult = results[1] as Result<RestaurantPageEntity>;

    if (restaurantsResult.isFailure) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: restaurantsResult.failure?.message,
        ),
      );
      return;
    }

    final page = restaurantsResult.data!;
    final cuisines = cuisinesResult.data ?? [];

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        cuisines: cuisines,
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
    await _hiveCache.saveHome(state);
  }

  Future<void> invalidateCache() async {
    _cache.invalidate();
    await _hiveCache.clearHomeForCurrentLocation();
  }

  Future<void> _mergeHomeFeed() async {
    final feedResult = await _homeRepository.loadHomeFeed();
    if (isClosed || feedResult.isFailure) return;

    final feed = feedResult.data;
    if (feed == null) return;

    emit(
      state.copyWith(
        notificationMessage: feed.notificationMessage,
        couponBanners: feed.couponBanners,
        sliders: feed.sliders,
        customerCarePhone: feed.customerCare?.phone,
        customerCareWhatsapp: feed.customerCare?.whatsapp,
      ),
    );
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
