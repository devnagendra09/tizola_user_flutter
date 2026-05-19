import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/cuisine_filter_store.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import 'restaurant_list_state.dart';

class RestaurantListCubit extends Cubit<RestaurantListState> {
  RestaurantListCubit(this._catalogRepository, this._cuisineFilterStore)
      : super(const RestaurantListState());

  final CatalogRepository _catalogRepository;
  final CuisineFilterStore _cuisineFilterStore;

  Future<void> loadRestaurants() async {
    emit(state.copyWith(status: RestaurantListStatus.loading, clearError: true));

    final result = await _catalogRepository.getRestaurants(
      page: 1,
      cuisineIds: _cuisineFilterStore.cuisineIds,
    );

    if (result.isFailure) {
      emit(
        state.copyWith(
          status: RestaurantListStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }

    final page = result.data!;
    emit(
      state.copyWith(
        status: RestaurantListStatus.loaded,
        restaurants: page.restaurants,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        isStoreAvailable: page.isStoreAvailable,
        cityImage: page.cityImage,
        emptyMessage: page.emptyMessage,
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
      cuisineIds: _cuisineFilterStore.cuisineIds,
    );

    if (result.isFailure) {
      emit(state.copyWith(isLoadingMore: false));
      return;
    }

    final page = result.data!;
    emit(
      state.copyWith(
        restaurants: [...state.restaurants, ...page.restaurants],
        currentPage: nextPage,
        totalPages: page.totalPages,
        isLoadingMore: false,
      ),
    );
  }
}
