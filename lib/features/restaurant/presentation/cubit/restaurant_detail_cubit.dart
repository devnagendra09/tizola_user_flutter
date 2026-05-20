import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/restaurant_detail_entities.dart';
import '../../domain/repositories/restaurant_repository.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit(
    this._repository, {
    required String seoUrl,
    String? fallbackName,
  }) : super(
          RestaurantDetailState(
            seoUrl: seoUrl,
            fallbackName: fallbackName,
          ),
        );

  final RestaurantRepository _repository;

  Future<void> loadInitial() async {
    emit(
      state.copyWith(
        status: RestaurantDetailStatus.loading,
        clearError: true,
        clearCartConflict: true,
      ),
    );

    final detailResult = await _repository.getRestaurantDetail(
      seoUrl: state.seoUrl,
    );
    final bannersResult = await _repository.getStoreBanners(
      seoUrl: state.seoUrl,
    );
    final menuResult = await _repository.getMenu(
      seoUrl: state.seoUrl,
      foodFilter: state.foodFilter,
    );
    final cartResult = await _repository.getCartSummary();

    if (menuResult.isFailure) {
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.failure,
          errorMessage: menuResult.failure?.message,
          detail: detailResult.data,
          banners: bannersResult.data ?? [],
        ),
      );
      return;
    }

    final menu = menuResult.data ?? [];
    emit(
      state.copyWith(
        status: RestaurantDetailStatus.loaded,
        detail: detailResult.data,
        banners: bannersResult.data ?? [],
        menuCategories: menu,
        displayCategories: _applySearch(menu, state.searchQuery),
        cartSummary: cartResult.data ?? const CartSummaryEntity(),
        clearError: true,
      ),
    );
  }

  Future<void> reloadMenu() async {
    final menuResult = await _repository.getMenu(
      seoUrl: state.seoUrl,
      foodFilter: state.foodFilter,
    );

    if (menuResult.isFailure) {
      emit(
        state.copyWith(
          errorMessage: menuResult.failure?.message,
        ),
      );
      return;
    }

    final menu = menuResult.data ?? [];
    emit(
      state.copyWith(
        status: RestaurantDetailStatus.loaded,
        menuCategories: menu,
        displayCategories: _applySearch(menu, state.searchQuery),
        clearError: true,
      ),
    );
    await refreshCart();
  }

  Future<void> setFoodFilter(RestaurantFoodFilter filter) async {
    if (state.foodFilter == filter) {
      await reloadMenuWithFilter(RestaurantFoodFilter.all);
      return;
    }
    await reloadMenuWithFilter(filter);
  }

  Future<void> reloadMenuWithFilter(RestaurantFoodFilter filter) async {
    emit(state.copyWith(foodFilter: filter));
    await reloadMenu();
  }

  void setSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        displayCategories: _applySearch(state.menuCategories, query),
        selectedCategoryIndex: 0,
      ),
    );
  }

  void selectCategory(int index) {
    emit(state.copyWith(selectedCategoryIndex: index));
  }

  Future<void> toggleFavourite() async {
    final result = await _repository.toggleFavourite(seoUrl: state.seoUrl);
    if (result.isSuccess && state.detail != null) {
      emit(
        state.copyWith(
          detail: RestaurantDetailEntity(
            name: state.detail!.name,
            isOpened: state.detail!.isOpened,
            isFavourite: !state.detail!.isFavourite,
            address: state.detail!.address,
            distance: state.detail!.distance,
          ),
        ),
      );
    }
  }

  Future<void> addItem(
    MenuItemEntity item, {
    String? optionId,
    List<String> addonIds = const [],
  }) async {
    if (item.isSoldOut || !item.isRestaurantOpen) return;

    emit(state.copyWith(isCartUpdating: true, clearError: true));
    final result = await _repository.addToCart(
      restaurantId: item.restaurantId,
      foodItemId: item.id,
      optionId: optionId,
      addonIds: addonIds,
    );

    if (result.isFailure) {
      emit(
        state.copyWith(
          isCartUpdating: false,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }

    final mutation = result.data!;
    if (!mutation.success) {
      if (mutation.errType == 'ORDER_DIFF_RESTAURANT') {
        emit(
          state.copyWith(
            isCartUpdating: false,
            cartConflict: CartConflictEvent(
              message: mutation.message ?? 'Cart has items from another restaurant',
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            isCartUpdating: false,
            errorMessage: mutation.message,
          ),
        );
      }
      return;
    }

    if (item.hasCustomizations) {
      await reloadMenu();
    } else {
      _patchItem(
        item.id,
        tempCartItemId: mutation.tempCartItemId,
        quantity: 1,
      );
    }
    await refreshCart();
    emit(state.copyWith(isCartUpdating: false));
  }

  Future<void> incrementItem(MenuItemEntity item) async {
    if (item.tempCartItemId == null) return;

    emit(state.copyWith(isCartUpdating: true));
    final nextQty = item.quantity + 1;
    final result = await _repository.updateCartQuantity(
      tempCartItemId: item.tempCartItemId!,
      quantity: nextQty,
    );

    if (result.isFailure || result.data?.success != true) {
      emit(
        state.copyWith(
          isCartUpdating: false,
          errorMessage: result.failure?.message ?? result.data?.message,
        ),
      );
      return;
    }

    _patchItem(item.id, quantity: nextQty);
    await refreshCart();
    emit(state.copyWith(isCartUpdating: false));
  }

  Future<void> decrementItem(MenuItemEntity item) async {
    if (item.tempCartItemId == null) return;

    emit(state.copyWith(isCartUpdating: true));
    if (item.quantity <= 1) {
      final result =
          await _repository.removeFromCart(tempCartItemId: item.tempCartItemId!);
      if (result.isFailure) {
        emit(
          state.copyWith(
            isCartUpdating: false,
            errorMessage: result.failure?.message,
          ),
        );
        return;
      }
      _patchItem(item.id, quantity: 0, clearTempCartItemId: true);
    } else {
      final nextQty = item.quantity - 1;
      final result = await _repository.updateCartQuantity(
        tempCartItemId: item.tempCartItemId!,
        quantity: nextQty,
      );
      if (result.isFailure || result.data?.success != true) {
        emit(
          state.copyWith(
            isCartUpdating: false,
            errorMessage: result.failure?.message ?? result.data?.message,
          ),
        );
        return;
      }
      _patchItem(item.id, quantity: nextQty);
    }

    await refreshCart();
    emit(state.copyWith(isCartUpdating: false));
  }

  Future<void> clearCartAndReload() async {
    emit(state.copyWith(clearCartConflict: true, isCartUpdating: true));
    final result = await _repository.clearCart();
    if (result.isFailure) {
      emit(
        state.copyWith(
          isCartUpdating: false,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    await reloadMenu();
    emit(state.copyWith(isCartUpdating: false));
  }

  void dismissCartConflict() {
    emit(state.copyWith(clearCartConflict: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> refreshCart() async {
    final result = await _repository.getCartSummary();
    if (result.isSuccess) {
      emit(state.copyWith(cartSummary: result.data ?? const CartSummaryEntity()));
    }
  }

  void _patchItem(
    String itemId, {
    String? tempCartItemId,
    int? quantity,
    bool clearTempCartItemId = false,
  }) {
    List<MenuCategoryEntity> patch(List<MenuCategoryEntity> source) {
      return source
          .map(
            (category) => category.copyWith(
              items: category.items
                  .map(
                    (item) => item.id == itemId
                        ? item.copyWith(
                            tempCartItemId: tempCartItemId,
                            quantity: quantity,
                            clearTempCartItemId: clearTempCartItemId,
                          )
                        : item,
                  )
                  .toList(),
            ),
          )
          .toList();
    }

    emit(
      state.copyWith(
        menuCategories: patch(state.menuCategories),
        displayCategories: patch(state.displayCategories),
      ),
    );
  }

  List<MenuCategoryEntity> _applySearch(
    List<MenuCategoryEntity> categories,
    String query,
  ) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return categories;

    final filtered = <MenuCategoryEntity>[];
    for (final category in categories) {
      final matches = category.items.where((item) {
        final name = item.name.toLowerCase();
        final desc = (item.description ?? '').toLowerCase();
        final q = trimmed.toLowerCase();
        return name.contains(q) || desc.contains(q);
      }).toList();
      if (matches.isNotEmpty) {
        filtered.add(category.copyWith(items: matches));
      } else if (category.name.toLowerCase().contains(trimmed.toLowerCase())) {
        filtered.add(category);
      }
    }
    return filtered;
  }
}
