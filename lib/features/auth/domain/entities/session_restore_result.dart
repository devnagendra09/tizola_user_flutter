import 'package:equatable/equatable.dart';

import '../../../location/domain/entities/delivery_location_entity.dart';
import 'user_entity.dart';

class SessionRestoreResult extends Equatable {
  const SessionRestoreResult({
    required this.user,
    this.needsRegistration = false,
    this.defaultLocation,
    this.requiresDeviceLocationSetup = false,
  });

  final UserEntity user;
  final bool needsRegistration;
  final DeliveryLocationEntity? defaultLocation;

  /// `default_location` present but lat/lng/address invalid — Android GetDeviceLocation.
  final bool requiresDeviceLocationSetup;

  @override
  List<Object?> get props => [
        user,
        needsRegistration,
        defaultLocation,
        requiresDeviceLocationSetup,
      ];
}
