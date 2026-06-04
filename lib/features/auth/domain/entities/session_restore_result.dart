import 'package:equatable/equatable.dart';

import '../../../location/domain/entities/delivery_location_entity.dart';
import 'user_entity.dart';

class SessionRestoreResult extends Equatable {
  const SessionRestoreResult({
    required this.user,
    this.needsRegistration = false,
    this.defaultLocation,
  });

  final UserEntity user;
  final bool needsRegistration;
  final DeliveryLocationEntity? defaultLocation;

  @override
  List<Object?> get props => [user, needsRegistration, defaultLocation];
}
