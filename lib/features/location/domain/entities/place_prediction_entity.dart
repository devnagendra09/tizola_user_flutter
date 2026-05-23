import 'package:equatable/equatable.dart';

/// Google Places Autocomplete prediction (Android `Autocomplete` list item).
class PlacePredictionEntity extends Equatable {
  const PlacePredictionEntity({
    required this.placeId,
    required this.description,
    this.primaryText,
    this.secondaryText,
  });

  final String placeId;
  final String description;
  final String? primaryText;
  final String? secondaryText;

  @override
  List<Object?> get props => [placeId, description, primaryText, secondaryText];
}
