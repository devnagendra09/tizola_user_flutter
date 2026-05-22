import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.refId,
    required this.restaurantName,
    this.deliveryAddress,
    this.paymentStatus,
    this.grandTotal,
    this.serviceStatus,
    this.cartItemsText,
    this.displayImage,
    this.deliveryPersonName,
    this.deliveryPersonContact,
    this.deliveryBoyImage,
    this.isFeedbackProvided = true,
    this.selfPickAccepted = false,
  });

  final String refId;
  final String restaurantName;
  final String? deliveryAddress;
  final String? paymentStatus;
  final String? grandTotal;
  final String? serviceStatus;
  final String? cartItemsText;
  final String? displayImage;
  final String? deliveryPersonName;
  final String? deliveryPersonContact;
  final String? deliveryBoyImage;

  /// Android `is_provided_feedback` — `0` means show feedback button.
  final bool isFeedbackProvided;
  final bool selfPickAccepted;

  bool get canLeaveFeedback => !isFeedbackProvided;

  @override
  List<Object?> get props => [
        refId,
        restaurantName,
        deliveryAddress,
        paymentStatus,
        grandTotal,
        serviceStatus,
        cartItemsText,
        displayImage,
        deliveryPersonName,
        deliveryPersonContact,
        deliveryBoyImage,
        isFeedbackProvided,
        selfPickAccepted,
      ];
}
