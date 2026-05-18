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
      ];
}
