import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/restaurant_entity.dart';

class RestaurantPageEntity extends Equatable {
  const RestaurantPageEntity({
    required this.restaurants,
    required this.totalPages,
    required this.currentPage,
    this.isStoreAvailable = true,
    this.cityImage,
    this.emptyMessage,
  });

  final List<RestaurantEntity> restaurants;
  final int totalPages;
  final int currentPage;
  final bool isStoreAvailable;
  final String? cityImage;
  final String? emptyMessage;

  bool get hasMore => currentPage < totalPages;

  @override
  List<Object?> get props =>
      [restaurants, totalPages, currentPage, isStoreAvailable, cityImage];
}
