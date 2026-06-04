import 'package:equatable/equatable.dart';

import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../../catalog/domain/enums/restaurant_price_option.dart';
import '../../../catalog/domain/enums/restaurant_sort_option.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../catalog/domain/entities/restaurant_entity.dart';
import '../../domain/entities/home_banner_entity.dart';

enum HomeStatus { initial, loading, loaded, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.notificationMessage,
    this.couponBanners = const [],
    this.sliders = const [],
    this.cuisines = const [],
    this.restaurants = const [],
    this.foodFilter = RestaurantFoodFilter.all,
    this.sortOption,
    this.priceOption,
    this.cuisineFilterIds = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.isReloadingRestaurants = false,
    this.isStoreAvailable = true,
    this.cityImage,
    this.emptyMessage,
    this.customerCarePhone,
    this.customerCareWhatsapp,
    this.errorMessage,
    this.openRestaurantCount = 0,
  });

  final HomeStatus status;
  final String? notificationMessage;
  final List<HomeBannerEntity> couponBanners;
  final List<HomeSliderEntity> sliders;
  final List<CuisineEntity> cuisines;
  final List<RestaurantEntity> restaurants;
  final RestaurantFoodFilter foodFilter;
  final RestaurantSortOption? sortOption;
  final RestaurantPriceOption? priceOption;
  final List<String> cuisineFilterIds;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool isReloadingRestaurants;
  final bool isStoreAvailable;
  final String? cityImage;
  final String? emptyMessage;
  final String? customerCarePhone;
  final String? customerCareWhatsapp;
  final String? errorMessage;
  final int openRestaurantCount;

  bool get hasMore => currentPage < totalPages;

  bool get hasRestaurantFilters =>
      sortOption != null ||
      priceOption != null ||
      cuisineFilterIds.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    String? notificationMessage,
    List<HomeBannerEntity>? couponBanners,
    List<HomeSliderEntity>? sliders,
    List<CuisineEntity>? cuisines,
    List<RestaurantEntity>? restaurants,
    RestaurantFoodFilter? foodFilter,
    RestaurantSortOption? sortOption,
    RestaurantPriceOption? priceOption,
    List<String>? cuisineFilterIds,
    bool clearSortOption = false,
    bool clearPriceOption = false,
    bool clearCuisineFilterIds = false,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isReloadingRestaurants,
    bool? isStoreAvailable,
    String? cityImage,
    String? emptyMessage,
    String? customerCarePhone,
    String? customerCareWhatsapp,
    String? errorMessage,
    int? openRestaurantCount,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      couponBanners: couponBanners ?? this.couponBanners,
      sliders: sliders ?? this.sliders,
      cuisines: cuisines ?? this.cuisines,
      restaurants: restaurants ?? this.restaurants,
      foodFilter: foodFilter ?? this.foodFilter,
      sortOption:
          clearSortOption ? null : (sortOption ?? this.sortOption),
      priceOption:
          clearPriceOption ? null : (priceOption ?? this.priceOption),
      cuisineFilterIds: clearCuisineFilterIds
          ? const []
          : (cuisineFilterIds ?? this.cuisineFilterIds),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isReloadingRestaurants:
          isReloadingRestaurants ?? this.isReloadingRestaurants,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      cityImage: cityImage ?? this.cityImage,
      emptyMessage: emptyMessage ?? this.emptyMessage,
      customerCarePhone: customerCarePhone ?? this.customerCarePhone,
      customerCareWhatsapp:
          customerCareWhatsapp ?? this.customerCareWhatsapp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      openRestaurantCount: openRestaurantCount ?? this.openRestaurantCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notificationMessage,
        couponBanners,
        sliders,
        cuisines,
        restaurants,
        foodFilter,
        sortOption,
        priceOption,
        cuisineFilterIds,
        currentPage,
        totalPages,
        isLoadingMore,
        isReloadingRestaurants,
        isStoreAvailable,
        cityImage,
        emptyMessage,
        customerCarePhone,
        customerCareWhatsapp,
        errorMessage,
        openRestaurantCount,
      ];
}
