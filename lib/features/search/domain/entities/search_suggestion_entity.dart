import 'package:equatable/equatable.dart';

/// Row from `restaurant_names` (Android `SearchProductModel`).
class SearchSuggestionEntity extends Equatable {
  const SearchSuggestionEntity({
    required this.restaurantName,
    this.seoUrl,
    this.distance,
    this.address,
    this.displayImage,
    this.type,
  });

  final String restaurantName;
  final String? seoUrl;
  final String? distance;
  final String? address;
  final String? displayImage;

  /// `Dish` → restaurant list with [search_key]; otherwise open restaurant detail.
  final String? type;

  bool get isDish => type != null && type!.toLowerCase() == 'dish';

  @override
  List<Object?> get props => [
        restaurantName,
        seoUrl,
        distance,
        address,
        displayImage,
        type,
      ];
}
