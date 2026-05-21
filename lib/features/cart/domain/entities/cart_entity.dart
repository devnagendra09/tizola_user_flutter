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
    this.providingSelfPickup = false,
  });

  final String name;
  final String? image;
  final String? address;
  final String? cuisineTypes;
  final String? minimumOrderAmount;

  /// Android `providing_self_pickup == "Yes"`.
  final bool providingSelfPickup;

  @override
  List<Object?> get props => [
        name,
        image,
        address,
        cuisineTypes,
        minimumOrderAmount,
        providingSelfPickup,
      ];
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
    this.appliedTipAmount,
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
  final String? appliedTipAmount;
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
        appliedTipAmount,
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
    this.imageUrl,
    this.enabled = true,
  });

  final String label;
  final String value;
  final String? imageUrl;
  final bool enabled;

  /// Android: `paymentMode.equals("Pay On Delivery", true)` on gateway `value`.
  bool get isCod {
    bool matches(String? text) {
      if (text == null || text.isEmpty) return false;
      final t = text.toLowerCase().trim();
      return t == 'pay on delivery' ||
          t == 'cash on delivery' ||
          t == 'cod' ||
          (t.contains('cash') && t.contains('delivery'));
    }

    return matches(value) || matches(label);
  }

  @override
  List<Object?> get props => [label, value, imageUrl, enabled];
}

/// `razor_pay_info` from `create_order` (key + meta_info for Checkout.open).
class RazorpayCheckoutInfo extends Equatable {
  const RazorpayCheckoutInfo({
    required this.key,
    required this.metaInfo,
  });

  final String key;
  final Map<String, dynamic> metaInfo;

  Map<String, dynamic> toCheckoutOptions() {
    final options = <String, dynamic>{'key': key};

    metaInfo.forEach((k, v) {
      if (v is Map) {
        options[k] = Map<String, dynamic>.from(
          v.map((key, val) => MapEntry(key.toString(), val)),
        );
      } else {
        options[k] = v;
      }
    });

    final amount = options['amount'];
    if (amount is String) {
      options['amount'] = int.tryParse(amount) ?? 0;
    } else if (amount is num) {
      options['amount'] = amount.toInt();
    }

    options.putIfAbsent('theme', () => {'color': '#0349A9'});
    options.putIfAbsent('name', () => 'Tizola');
    return options;
  }

  @override
  List<Object?> get props => [key, metaInfo];
}

class CreateOrderResult extends Equatable {
  const CreateOrderResult({
    required this.refId,
    this.razorpayInfo,
    this.paymentGatewayWebUrl,
  });

  final String refId;
  final RazorpayCheckoutInfo? razorpayInfo;

  /// Server web checkout when `razor_pay_info` is absent.
  final String? paymentGatewayWebUrl;

  bool get hasRazorpay => razorpayInfo != null;

  bool get hasWebPayment =>
      paymentGatewayWebUrl != null && paymentGatewayWebUrl!.isNotEmpty;

  @override
  List<Object?> get props => [refId, razorpayInfo, paymentGatewayWebUrl];
}
