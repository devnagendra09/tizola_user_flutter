import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../domain/entities/restaurant_page_entity.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository, this._catalogRepository)
      : super(const HomeState());

  final HomeRepository _homeRepository;
  final CatalogRepository _catalogRepository;

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    // Promotional APIs (weather notification, coupons, sliders) must not block restaurants.
    _mergeHomeFeed();

    final results = await Future.wait([
      _catalogRepository.getCuisines(),
      _catalogRepository.getRestaurants(
        page: 1,
        foodFilter: state.foodFilter,
      ),
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

  Future<void> refresh() => loadHome();

  Future<void> setFoodFilter(RestaurantFoodFilter filter) async {
    if (state.foodFilter == filter) {
      await _reloadRestaurants(filter: RestaurantFoodFilter.all);
      return;
    }
    await _reloadRestaurants(filter: filter);
  }

  Future<void> _reloadRestaurants({required RestaurantFoodFilter filter}) async {
    emit(
      state.copyWith(
        foodFilter: filter,
        status: HomeStatus.loading,
        clearError: true,
      ),
    );

    final result = await _catalogRepository.getRestaurants(
      page: 1,
      foodFilter: filter,
    );

    if (isClosed) return;

    if (result.isFailure) {
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
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
        clearError: true,
      ),
    );
  }

  Future<void> loadMoreRestaurants() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final nextPage = state.currentPage + 1;
    final result = await _catalogRepository.getRestaurants(
      page: nextPage,
      foodFilter: state.foodFilter,
    );

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
  }
}
