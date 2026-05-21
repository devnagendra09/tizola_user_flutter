import 'package:equatable/equatable.dart';

/// Active order strip from `customer/check_for_any_in_progress_order` (Android `viewTrack`).
class InProgressOrderEntity extends Equatable {
  const InProgressOrderEntity({
    required this.refId,
    required this.message,
    this.deliveryOtp,
    this.hasLiveTracking = false,
    this.selfPickAccepted = false,
  });

  final String refId;
  final String message;
  final String? deliveryOtp;
  final bool hasLiveTracking;
  final bool selfPickAccepted;

  String get trackButtonLabel =>
      hasLiveTracking ? 'Live Tracking' : 'View Details';

  @override
  List<Object?> get props => [
        refId,
        message,
        deliveryOtp,
        hasLiveTracking,
        selfPickAccepted,
      ];
}
