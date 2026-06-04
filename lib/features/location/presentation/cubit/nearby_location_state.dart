import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_location_entity.dart';

enum NearbyLocationStatus {
  initial,
  locating,
  addressReady,
  navigateToMain,
  navigateToDeviceLocationSetup,
  failure,
}

class NearbyLocationState extends Equatable {
  const NearbyLocationState({
    this.status = NearbyLocationStatus.initial,
    this.location,
    this.showAddressCard = false,
    this.errorMessage,
  });

  final NearbyLocationStatus status;
  final DeliveryLocationEntity? location;
  final bool showAddressCard;
  final String? errorMessage;

  NearbyLocationState copyWith({
    NearbyLocationStatus? status,
    DeliveryLocationEntity? location,
    bool? showAddressCard,
    String? errorMessage,
  }) {
    return NearbyLocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      showAddressCard: showAddressCard ?? this.showAddressCard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, location, showAddressCard, errorMessage];
}
