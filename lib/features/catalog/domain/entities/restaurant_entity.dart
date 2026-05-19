import 'package:equatable/equatable.dart';

enum FoodType { both, veg, nonVeg }

class RestaurantEntity extends Equatable {
  const RestaurantEntity({
    required this.id,
    required this.name,
    this.seoUrl,
    this.imageUrl,
    this.cuisineTypes,
    this.estimateTime,
    this.offer,
    this.isOpened,
    this.distance,
    this.address,
    this.rating,
    this.minimumOrderAmount,
    this.foodType = FoodType.both,
    this.isExclusive = false,
    this.isFavourite = false,
  });

  final String id;
  final String name;
  final String? seoUrl;
  final String? imageUrl;
  final String? cuisineTypes;
  final String? estimateTime;
  final String? offer;
  final String? isOpened;
  final String? distance;
  final String? address;
  final double? rating;
  final String? minimumOrderAmount;
  final FoodType foodType;
  final bool isExclusive;
  final bool isFavourite;

  bool get isOpen => (isOpened ?? '').toLowerCase() == 'open';

  @override
  List<Object?> get props => [
        id,
        name,
        seoUrl,
        imageUrl,
        cuisineTypes,
        estimateTime,
        offer,
        isOpened,
        distance,
        address,
        rating,
        minimumOrderAmount,
        foodType,
        isExclusive,
        isFavourite,
      ];
}
