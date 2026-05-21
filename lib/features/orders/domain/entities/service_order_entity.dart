import 'package:equatable/equatable.dart';

class ServiceOrderStatusLog extends Equatable {
  const ServiceOrderStatusLog({
    required this.label,
    this.dateTime,
    this.isActive = false,
    this.imageUrl,
  });

  final String label;
  final String? dateTime;
  final bool isActive;
  final String? imageUrl;

  @override
  List<Object?> get props => [label, dateTime, isActive, imageUrl];
}

class ServiceOrderCartItem extends Equatable {
  const ServiceOrderCartItem({
    required this.name,
    this.quantity,
    this.price,
  });

  final String name;
  final String? quantity;
  final String? price;

  @override
  List<Object?> get props => [name, quantity, price];
}

class ServiceOrderRestaurant extends Equatable {
  const ServiceOrderRestaurant({
    required this.name,
    this.displayAddress,
    this.mobile,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String? displayAddress;
  final String? mobile;
  final String? imageUrl;
  final String? latitude;
  final String? longitude;

  @override
  List<Object?> get props =>
      [name, displayAddress, mobile, imageUrl, latitude, longitude];
}

/// `customer/service_order_view` — Android `OrderSummaryFragment` / `OrderTrackerActivity`.
class ServiceOrderEntity extends Equatable {
  const ServiceOrderEntity({
    required this.refId,
    required this.serviceStatus,
    required this.grandTotal,
    required this.restaurant,
    required this.statusLog,
    required this.cartItems,
    this.deliveryOtp,
    this.addressType,
    this.deliveryAddress,
    this.customerCareNumber,
    this.customerCareWhatsApp,
    this.selfPickAccepted = false,
    this.remainingSeconds,
    this.subTotal,
    this.deliveryCharges,
    this.discount,
    this.taxes,
    this.paidAmount,
    this.paymentStatus,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  final String refId;
  final String serviceStatus;
  final String grandTotal;
  final ServiceOrderRestaurant restaurant;
  final List<ServiceOrderStatusLog> statusLog;
  final List<ServiceOrderCartItem> cartItems;
  final String? deliveryOtp;
  final String? addressType;
  final String? deliveryAddress;
  final String? customerCareNumber;
  final String? customerCareWhatsApp;
  final bool selfPickAccepted;
  final int? remainingSeconds;
  final String? subTotal;
  final String? deliveryCharges;
  final String? discount;
  final String? taxes;
  final String? paidAmount;
  final String? paymentStatus;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  String get descriptionLine =>
      '$serviceStatus | ${cartItems.length} Items, Rs $grandTotal';

  bool get isOutForDelivery =>
      serviceStatus.toLowerCase() == 'out for delivery';

  bool get shouldListenDriverLocation => isOutForDelivery && !selfPickAccepted;

  @override
  List<Object?> get props => [
        refId,
        serviceStatus,
        grandTotal,
        restaurant,
        statusLog,
        cartItems,
        deliveryOtp,
        addressType,
        deliveryAddress,
        customerCareNumber,
        customerCareWhatsApp,
        selfPickAccepted,
        remainingSeconds,
        subTotal,
        deliveryCharges,
        discount,
        taxes,
        paidAmount,
        paymentStatus,
        deliveryLatitude,
        deliveryLongitude,
      ];
}
