import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/restaurant_entity.dart';

enum RestaurantListStatus { initial, loading, loaded, failure }

class RestaurantListState extends Equatable {
  const RestaurantListState({
    this.status = RestaurantListStatus.initial,
    this.restaurants = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.isStoreAvailable = true,
    this.cityImage,
    this.emptyMessage,
    this.errorMessage,
  });

  final RestaurantListStatus status;
  final List<RestaurantEntity> restaurants;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool isStoreAvailable;
  final String? cityImage;
  final String? emptyMessage;
  final String? errorMessage;

  bool get hasMore => currentPage < totalPages;

  RestaurantListState copyWith({
    RestaurantListStatus? status,
    List<RestaurantEntity>? restaurants,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isStoreAvailable,
    String? cityImage,
    String? emptyMessage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RestaurantListState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      cityImage: cityImage ?? this.cityImage,
      emptyMessage: emptyMessage ?? this.emptyMessage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        restaurants,
        currentPage,
        totalPages,
        isLoadingMore,
        isStoreAvailable,
        cityImage,
        emptyMessage,
        errorMessage,
      ];
}
