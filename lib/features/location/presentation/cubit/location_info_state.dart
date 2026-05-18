import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_location_entity.dart';

enum LocationInfoStatus { initial, loading, loaded, saving, failure }

class LocationInfoState extends Equatable {
  const LocationInfoState({
    this.status = LocationInfoStatus.initial,
    this.savedAddresses = const [],
    this.draft,
    this.addressType = 'Home',
    this.showOtherLabel = false,
    this.showEditButton = false,
    this.errorMessage,
    this.message,
  });

  final LocationInfoStatus status;
  final List<DeliveryLocationEntity> savedAddresses;
  final DeliveryLocationEntity? draft;
  final String addressType;
  final bool showOtherLabel;
  final bool showEditButton;
  final String? errorMessage;
  final String? message;

  bool get hasMapPreview =>
      draft != null && draft!.address.isNotEmpty;

  LocationInfoState copyWith({
    LocationInfoStatus? status,
    List<DeliveryLocationEntity>? savedAddresses,
    DeliveryLocationEntity? draft,
    String? addressType,
    bool? showOtherLabel,
    bool? showEditButton,
    String? errorMessage,
    String? message,
    bool clearMessage = false,
  }) {
    return LocationInfoState(
      status: status ?? this.status,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      draft: draft ?? this.draft,
      addressType: addressType ?? this.addressType,
      showOtherLabel: showOtherLabel ?? this.showOtherLabel,
      showEditButton: showEditButton ?? this.showEditButton,
      errorMessage: errorMessage,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        status,
        savedAddresses,
        draft,
        addressType,
        showOtherLabel,
        showEditButton,
        errorMessage,
        message,
      ];
}
