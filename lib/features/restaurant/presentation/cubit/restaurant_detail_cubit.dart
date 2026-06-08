import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/restaurant_menu_cache.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/restaurant_detail_entities.dart';
import '../../domain/repositories/restaurant_repository.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit(
    this._repository,
    this._menuCache, {
    required String seoUrl,
    String? fallbackName,
    RestaurantDetailEntity? initialDetail,
  }) : super(
          RestaurantDetailState(
            seoUrl: seoUrl,
            fallbackName: fallbackName,
            detail: initialDetail,
            status: initialDetail != null
                ? RestaurantDetailStatus.loaded
                : RestaurantDetailStatus.initial,
          ),
        );

  final RestaurantRepository _repository;
  final RestaurantMenuCache _menuCache;
  Timer? _cartRefreshDebounce;
  var _loadGeneration = 0;

  @override
  Future<void> close() {
    _cartRefreshDebounce?.cancel();
    return super.close();
  }

  String get _filterKey => state.foodFilter.name;

  /// P1: menu + cart (show list). P2: header + banners (background).
  Future<void> loadInitial({bool force = false}) async {
    final generation = ++_loadGeneration;
    final hasShell = state.detail != null || state.fallbackName != null;

    final cachedMenu = force
        ? null
        : _menuCache.read(state.seoUrl, _filterKey);

    if (cachedMenu != null && cachedMenu.isNotEmpty) {
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.loaded,
          menuCategories: cachedMenu,
          displayCategories: _applySearch(cachedMenu, state.searchQuery),
          isLoadingMenu: false,
          clearError: true,
        ),
      );
      unawaited(_refreshMenuInBackground(generation));
      unawaited(_loadSecondaryContent(generation));
      unawaited(_loadCartSummary());
      return;
    }

    emit(
      state.copyWith(
        status: hasShell
            ? RestaurantDetailStatus.loaded
            : RestaurantDetailStatus.loading,
        isLoadingMenu: true,
        clearError: true,
        clearCartConflict: true,
      ),
    );

    final menuResult = await _fetchMenuWithRetry();
    if (isClosed || generation != _loadGeneration) return;

    if (menuResult.isFailure) {
      if (state.menuCategories.isEmpty) {
        emit(
          state.copyWith(
            status: RestaurantDetailStatus.failure,
            isLoadingMenu: false,
            errorMessage: menuResult.failure?.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoadingMenu: false,
            errorMessage: menuResult.failure?.message,
          ),
        );
      }
      unawaited(_loadSecondaryContent(generation));
      return;
    }

    final menu = menuResult.data ?? [];
    _menuCache.save(state.seoUrl, _filterKey, menu);

    emit(
      state.copyWith(
        status: RestaurantDetailStatus.loaded,
        menuCategories: menu,
        displayCategories: _applySearch(menu, state.searchQuery),
        isLoadingMenu: false,
        clearError: true,
      ),
    );

    unawaited(_loadSecondaryContent(generation));
    unawaited(_loadCartSummary());
  }

  Future<void> _refreshMenuInBackground(int generation) async {
    final menuResult = await _fetchMenuWithRetry();
    if (isClosed || generation != _loadGeneration) return;
    if (menuResult.isFailure) return;

    final menu = menuResult.data ?? [];
    if (menu.isEmpty) return;

    _menuCache.save(state.seoUrl, _filterKey, menu);
    emit(
      state.copyWith(
        menuCategories: menu,
        displayCategories: _applySearch(menu, state.searchQuery),
      ),
    );
  }

  Future<void> _loadSecondaryContent(int generation) async {
    final results = await Future.wait([
      _repository.getRestaurantDetail(seoUrl: state.seoUrl),
      _repository.getStoreBanners(seoUrl: state.seoUrl),
    ]);

    if (isClosed || generation != _loadGeneration) return;

    final detailResult = results[0] as Result<RestaurantDetailEntity>;
    final bannersResult = results[1] as Result<List<StoreBannerEntity>>;

    emit(
      state.copyWith(
        detail: detailResult.isSuccess ? detailResult.data : state.detail,
        banners: bannersResult.isSuccess
            ? (bannersResult.data ?? state.banners)
            : state.banners,
      ),
    );
  }

  Future<void> _loadCartSummary() async {
    final cartResult = await _repository.getCartSummary();
    if (isClosed) return;
    if (cartResult.isSuccess) {
      emit(
        state.copyWith(
          cartSummary: cartResult.data ?? const CartSummaryEntity(),
        ),
      );
    }
  }

  Future<Result<List<MenuCategoryEntity>>> _fetchMenuWithRetry({
    int maxAttempts = 2,
  }) async {
    Result<List<MenuCategoryEntity>>? last;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (isClosed) break;
      }
      last = await _repository.getMenu(
        seoUrl: state.seoUrl,
        foodFilter: state.foodFilter,
      );
      if (last.isSuccess) return last;
    }
    return last ?? Result.failure(const NetworkFailure());
  }

  Future<void> reloadMenu() async {
    emit(state.copyWith(isLoadingMenu: true, clearError: true));

    final menuResult = await _fetchMenuWithRetry();

    if (menuResult.isFailure) {
      emit(
        state.copyWith(
          isLoadingMenu: false,
          errorMessage: menuResult.failure?.message,
        ),
      );
      return;
    }

    final menu = menuResult.data ?? [];
    _menuCache.save(state.seoUrl, _filterKey, menu);

    emit(
      state.copyWith(
        status: RestaurantDetailStatus.loaded,
        menuCategories: menu,
        displayCategories: _applySearch(menu, state.searchQuery),
        isLoadingMenu: false,
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
    if (state.isItemCartPending(item.id)) return;

    final snapshot = _itemSnapshot(item);
    _setItemPending(item.id, true);
    emit(state.copyWith(clearError: true));

    if (!item.hasCustomizations) {
      _patchItem(
        item.id,
        tempCartItemId: MenuItemEntity.pendingCartLineId(item.id),
        quantity: 1,
      );
      _applyOptimisticCartDelta(item, 1);
    }

    final result = await _repository.addToCart(
      restaurantId: item.restaurantId,
      foodItemId: item.id,
      optionId: optionId,
      addonIds: addonIds,
    );

    if (result.isFailure) {
      _restoreItem(item.id, snapshot);
      if (!item.hasCustomizations) {
        _applyOptimisticCartDelta(item, -1);
      }
      _setItemPending(item.id, false);
      emit(state.copyWith(errorMessage: result.failure?.message));
      return;
    }

    final mutation = result.data!;
    if (!mutation.success) {
      _restoreItem(item.id, snapshot);
      if (!item.hasCustomizations) {
        _applyOptimisticCartDelta(item, -1);
      }
      _setItemPending(item.id, false);
      if (mutation.errType == 'ORDER_DIFF_RESTAURANT') {
        emit(
          state.copyWith(
            cartConflict: CartConflictEvent(
              message:
                  mutation.message ?? 'Cart has items from another restaurant',
            ),
          ),
        );
      } else {
        emit(state.copyWith(errorMessage: mutation.message));
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
    _setItemPending(item.id, false);
    _scheduleCartRefresh();
  }

  Future<void> incrementItem(MenuItemEntity item) async {
    if (!item.isCartLineReady || state.isItemCartPending(item.id)) return;

    final snapshot = _itemSnapshot(item);
    final nextQty = item.quantity + 1;
    _setItemPending(item.id, true);
    _patchItem(item.id, quantity: nextQty);
    _applyOptimisticCartDelta(item, 1);

    final result = await _repository.updateCartQuantity(
      tempCartItemId: item.tempCartItemId!,
      quantity: nextQty,
    );

    if (result.isFailure || result.data?.success != true) {
      _restoreItem(item.id, snapshot);
      _applyOptimisticCartDelta(item, -1);
      _setItemPending(item.id, false);
      emit(
        state.copyWith(
          errorMessage: result.failure?.message ?? result.data?.message,
        ),
      );
      return;
    }

    _setItemPending(item.id, false);
    _scheduleCartRefresh();
  }

  Future<void> decrementItem(MenuItemEntity item) async {
    if (!item.isCartLineReady || state.isItemCartPending(item.id)) return;

    final snapshot = _itemSnapshot(item);
    _setItemPending(item.id, true);

    if (item.quantity <= 1) {
      _patchItem(item.id, quantity: 0, clearTempCartItemId: true);
      _applyOptimisticCartDelta(item, -1);

      final result =
          await _repository.removeFromCart(tempCartItemId: item.tempCartItemId!);
      if (result.isFailure) {
        _restoreItem(item.id, snapshot);
        _applyOptimisticCartDelta(item, 1);
        _setItemPending(item.id, false);
        emit(state.copyWith(errorMessage: result.failure?.message));
        return;
      }
    } else {
      final nextQty = item.quantity - 1;
      _patchItem(item.id, quantity: nextQty);
      _applyOptimisticCartDelta(item, -1);

      final result = await _repository.updateCartQuantity(
        tempCartItemId: item.tempCartItemId!,
        quantity: nextQty,
      );
      if (result.isFailure || result.data?.success != true) {
        _restoreItem(item.id, snapshot);
        _applyOptimisticCartDelta(item, 1);
        _setItemPending(item.id, false);
        emit(
          state.copyWith(
            errorMessage: result.failure?.message ?? result.data?.message,
          ),
        );
        return;
      }
    }

    _setItemPending(item.id, false);
    _scheduleCartRefresh();
  }

  Future<void> clearCartAndReload() async {
    emit(state.copyWith(clearCartConflict: true, isClearingCart: true));
    final result = await _repository.clearCart();
    if (result.isFailure) {
      emit(
        state.copyWith(
          isClearingCart: false,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    _menuCache.invalidate(state.seoUrl);
    await reloadMenu();
    emit(
      state.copyWith(
        isClearingCart: false,
        cartSummary: const CartSummaryEntity(),
      ),
    );
  }

  void dismissCartConflict() {
    emit(state.copyWith(clearCartConflict: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> refreshCart() async {
    final result = await _repository.getCartSummary();
    if (result.isSuccess && !isClosed) {
      emit(state.copyWith(cartSummary: result.data ?? const CartSummaryEntity()));
    }
  }

  /// After cart screen (or checkout) — refresh bar and menu qty badges from server.
  Future<void> syncAfterCartScreen() async {
    final result = await _repository.getCartSummary();
    if (isClosed) return;

    final summary = result.data ?? const CartSummaryEntity();
    emit(state.copyWith(cartSummary: summary));

    if (!summary.hasItems) {
      await reloadMenu();
    }
  }

  void _scheduleCartRefresh() {
    _cartRefreshDebounce?.cancel();
    _cartRefreshDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!isClosed) {
        unawaited(refreshCart());
      }
    });
  }

  void _setItemPending(String itemId, bool pending) {
    final next = Set<String>.from(state.pendingCartItemIds);
    if (pending) {
      next.add(itemId);
    } else {
      next.remove(itemId);
    }
    emit(state.copyWith(pendingCartItemIds: next));
  }

  void _applyOptimisticCartDelta(MenuItemEntity item, int lineDelta) {
    if (lineDelta == 0) return;
    final count = (state.cartSummary.itemCount + lineDelta).clamp(0, 9999);
    final currentSub =
        double.tryParse(state.cartSummary.subTotal?.replaceAll(',', '') ?? '') ??
            0;
    final nextSub =
        (currentSub + item.applicablePrice * lineDelta).clamp(0, double.infinity);
    emit(
      state.copyWith(
        cartSummary: CartSummaryEntity(
          itemCount: count,
          subTotal: nextSub.round().toString(),
        ),
      ),
    );
  }

  _ItemSnapshot _itemSnapshot(MenuItemEntity item) => _ItemSnapshot(
        quantity: item.quantity,
        tempCartItemId: item.tempCartItemId,
      );

  void _restoreItem(String itemId, _ItemSnapshot snapshot) {
    if (snapshot.quantity <= 0) {
      _patchItem(itemId, quantity: 0, clearTempCartItemId: true);
    } else {
      _patchItem(
        itemId,
        quantity: snapshot.quantity,
        tempCartItemId: snapshot.tempCartItemId,
      );
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

class _ItemSnapshot {
  const _ItemSnapshot({
    required this.quantity,
    required this.tempCartItemId,
  });

  final int quantity;
  final String? tempCartItemId;
}
