import 'package:equatable/equatable.dart';

class RestaurantBusinessHourEntity extends Equatable {
  const RestaurantBusinessHourEntity({
    required this.weekName,
    required this.timings,
  });

  final String weekName;
  final String timings;

  @override
  List<Object?> get props => [weekName, timings];
}

class RestaurantAboutEntity extends Equatable {
  const RestaurantAboutEntity({
    this.description = '',
    this.displayAddress = '',
    this.businessHours = const [],
    this.latitude,
    this.longitude,
  });

  final String description;
  final String displayAddress;
  final List<RestaurantBusinessHourEntity> businessHours;
  final double? latitude;
  final double? longitude;

  bool get hasMap =>
      latitude != null &&
      longitude != null &&
      latitude != 0 &&
      longitude != 0;

  @override
  List<Object?> get props => [
        description,
        displayAddress,
        businessHours,
        latitude,
        longitude,
      ];
}
