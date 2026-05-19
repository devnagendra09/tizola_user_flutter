import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  const CartItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    required this.applicablePrice,
    this.image,
    this.optionsName,
    this.addonsNames,
  });

  final String id;
  final String name;
  final int quantity;
  final double applicablePrice;
  final String? image;
  final String? optionsName;
  final String? addonsNames;

  String get customization {
    final parts = [
      if (optionsName != null && optionsName!.isNotEmpty) optionsName,
      if (addonsNames != null && addonsNames!.isNotEmpty) addonsNames,
    ];
    return parts.join(' · ');
  }

  @override
  List<Object?> get props =>
      [id, name, quantity, applicablePrice, image, optionsName, addonsNames];
}

class CartRestaurantInfoEntity extends Equatable {
  const CartRestaurantInfoEntity({
    required this.name,
    this.image,
    this.address,
    this.cuisineTypes,
    this.minimumOrderAmount,
  });

  final String name;
  final String? image;
  final String? address;
  final String? cuisineTypes;
  final String? minimumOrderAmount;

  @override
  List<Object?> get props =>
      [name, image, address, cuisineTypes, minimumOrderAmount];
}

class CartTaxEntity extends Equatable {
  const CartTaxEntity({
    required this.name,
    required this.amount,
  });

  final String name;
  final String amount;

  @override
  List<Object?> get props => [name, amount];
}

class CartEntity extends Equatable {
  const CartEntity({
    this.restaurant,
    this.items = const [],
    this.taxes = const [],
    this.subTotal,
    this.couponCode,
    this.appliedDiscountAmount,
    this.appliedTaxAmount,
    this.appliedDeliveryCharge,
    this.promotionWalletAmount,
    this.grandTotal,
    this.couponDiscountMessage,
    this.hasCouponDiscount = false,
    this.restaurantId,
    this.deliveryAddress,
  });

  final CartRestaurantInfoEntity? restaurant;
  final List<CartItemEntity> items;
  final List<CartTaxEntity> taxes;
  final String? subTotal;
  final String? couponCode;
  final String? appliedDiscountAmount;
  final String? appliedTaxAmount;
  final String? appliedDeliveryCharge;
  final String? promotionWalletAmount;
  final String? grandTotal;
  final String? couponDiscountMessage;
  final bool hasCouponDiscount;
  final String? restaurantId;
  final String? deliveryAddress;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        restaurant,
        items,
        taxes,
        subTotal,
        couponCode,
        appliedDiscountAmount,
        appliedTaxAmount,
        appliedDeliveryCharge,
        promotionWalletAmount,
        grandTotal,
        couponDiscountMessage,
        hasCouponDiscount,
        restaurantId,
        deliveryAddress,
      ];
}

class PaymentOptionEntity extends Equatable {
  const PaymentOptionEntity({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  bool get isCod => value.toLowerCase().contains('delivery');

  @override
  List<Object?> get props => [label, value];
}

class CreateOrderResult extends Equatable {
  const CreateOrderResult({
    required this.refId,
    this.requiresOnlinePayment = false,
  });

  final String refId;
  final bool requiresOnlinePayment;

  @override
  List<Object?> get props => [refId, requiresOnlinePayment];
}
