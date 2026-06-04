import 'package:equatable/equatable.dart';

/// `customer/check_for_feedback_action` data — Android `ReviewOptionFragment`.
class PendingFeedbackEntity extends Equatable {
  const PendingFeedbackEntity({
    required this.refId,
    this.restaurantName,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.displayImage,
    this.deliveryBoyImage,
    this.selfPickAccepted,
  });

  final String refId;
  final String? restaurantName;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final String? displayImage;
  final String? deliveryBoyImage;
  final String? selfPickAccepted;

  @override
  List<Object?> get props => [
        refId,
        restaurantName,
        deliveryPersonName,
        deliveryPersonPhone,
        displayImage,
        deliveryBoyImage,
        selfPickAccepted,
      ];
}
