import 'package:equatable/equatable.dart';

class LocationDraft extends Equatable {
  const LocationDraft({
    required this.latitude,
    required this.longitude,
    required this.addressLine,
    required this.city,
  });

  final double latitude;
  final double longitude;
  final String addressLine;
  final String city;

  @override
  List<Object?> get props => [latitude, longitude, addressLine, city];
}

enum LocationOnboardingStatus {
  initial,
  resolving,
  ready,
  saving,
  saved,
  permissionDenied,
  serviceDisabled,
  failure,
}

class LocationOnboardingState extends Equatable {
  const LocationOnboardingState({
    this.status = LocationOnboardingStatus.initial,
    this.draft,
    this.errorMessage,
  });

  final LocationOnboardingStatus status;
  final LocationDraft? draft;
  final String? errorMessage;

  LocationOnboardingState copyWith({
    LocationOnboardingStatus? status,
    LocationDraft? draft,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationOnboardingState(
      status: status ?? this.status,
      draft: draft ?? this.draft,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, draft, errorMessage];
}
