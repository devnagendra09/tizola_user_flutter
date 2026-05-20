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
    this.fromTime,
    this.toTime,
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
  final String? fromTime;
  final String? toTime;
  final String? distance;
  final String? address;
  final double? rating;
  final String? minimumOrderAmount;
  final FoodType foodType;
  final bool isExclusive;
  final bool isFavourite;

  bool get isOpen => (isOpened ?? '').toLowerCase() == 'open';

  bool get showVegBadge =>
      foodType == FoodType.veg || foodType == FoodType.both;

  bool get showNonVegBadge =>
      foodType == FoodType.nonVeg || foodType == FoodType.both;

  String? get formattedOpenTime => _formatTime(fromTime);

  String? get formattedCloseTime => _formatTime(toTime);

  static String? _formatTime(String? raw) {
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }
    final trimmed = raw.trim();
    final parts = trimmed.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return trimmed;
  }

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
        fromTime,
        toTime,
        distance,
        address,
        rating,
        minimumOrderAmount,
        foodType,
        isExclusive,
        isFavourite,
      ];
}
