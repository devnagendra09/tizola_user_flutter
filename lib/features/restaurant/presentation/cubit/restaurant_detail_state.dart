import 'package:equatable/equatable.dart';

import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/restaurant_detail_entities.dart';

enum RestaurantDetailStatus { initial, loading, loaded, failure }

class CartConflictEvent extends Equatable {
  const CartConflictEvent({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class RestaurantDetailState extends Equatable {
  const RestaurantDetailState({
    required this.seoUrl,
    this.fallbackName,
    this.status = RestaurantDetailStatus.initial,
    this.detail,
    this.banners = const [],
    this.menuCategories = const [],
    this.displayCategories = const [],
    this.selectedCategoryIndex = 0,
    this.foodFilter = RestaurantFoodFilter.all,
    this.searchQuery = '',
    this.cartSummary = const CartSummaryEntity(),
    this.pendingCartItemIds = const {},
    this.isClearingCart = false,
    this.cartConflict,
    this.errorMessage,
  });

  final String seoUrl;
  final String? fallbackName;
  final RestaurantDetailStatus status;
  final RestaurantDetailEntity? detail;
  final List<StoreBannerEntity> banners;
  final List<MenuCategoryEntity> menuCategories;
  final List<MenuCategoryEntity> displayCategories;
  final int selectedCategoryIndex;
  final RestaurantFoodFilter foodFilter;
  final String searchQuery;
  final CartSummaryEntity cartSummary;
  final Set<String> pendingCartItemIds;
  final bool isClearingCart;
  final CartConflictEvent? cartConflict;
  final String? errorMessage;

  String get title => detail?.name ?? fallbackName ?? 'Restaurant';

  bool isItemCartPending(String itemId) => pendingCartItemIds.contains(itemId);

  RestaurantDetailState copyWith({
    RestaurantDetailStatus? status,
    RestaurantDetailEntity? detail,
    List<StoreBannerEntity>? banners,
    List<MenuCategoryEntity>? menuCategories,
    List<MenuCategoryEntity>? displayCategories,
    int? selectedCategoryIndex,
    RestaurantFoodFilter? foodFilter,
    String? searchQuery,
    CartSummaryEntity? cartSummary,
    Set<String>? pendingCartItemIds,
    bool? isClearingCart,
    CartConflictEvent? cartConflict,
    String? errorMessage,
    bool clearCartConflict = false,
    bool clearError = false,
  }) {
    return RestaurantDetailState(
      seoUrl: seoUrl,
      fallbackName: fallbackName,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      banners: banners ?? this.banners,
      menuCategories: menuCategories ?? this.menuCategories,
      displayCategories: displayCategories ?? this.displayCategories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      foodFilter: foodFilter ?? this.foodFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      cartSummary: cartSummary ?? this.cartSummary,
      pendingCartItemIds: pendingCartItemIds ?? this.pendingCartItemIds,
      isClearingCart: isClearingCart ?? this.isClearingCart,
      cartConflict: clearCartConflict ? null : (cartConflict ?? this.cartConflict),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        seoUrl,
        fallbackName,
        status,
        detail,
        banners,
        menuCategories,
        displayCategories,
        selectedCategoryIndex,
        foodFilter,
        searchQuery,
        cartSummary,
        pendingCartItemIds,
        isClearingCart,
        cartConflict,
        errorMessage,
      ];
}
