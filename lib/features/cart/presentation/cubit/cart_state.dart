import 'package:equatable/equatable.dart';

import '../../../location/domain/entities/delivery_location_entity.dart';
import '../../domain/entities/cart_entity.dart';

enum CartStatus { initial, loading, loaded, failure, updating }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart = const CartEntity(),
    this.deliveryLocation,
    this.couponCodeInput = '',
    this.pendingCouponCode,
    this.isSelfPickup = false,
    this.selectedTipAmount,
    this.customTipInput = '',
    this.showCustomTipField = false,
    this.tipAmounts = const [],
    this.errorMessage,
  });

  final CartStatus status;
  final CartEntity cart;
  final DeliveryLocationEntity? deliveryLocation;
  final String couponCodeInput;

  /// Coupon chosen on offers screen; applied on next cart refresh (Android `couponCode`).
  final String? pendingCouponCode;
  final bool isSelfPickup;
  final String? selectedTipAmount;
  final String customTipInput;
  final bool showCustomTipField;
  final List<String> tipAmounts;
  final String? errorMessage;

  bool get isEmpty => cart.isEmpty;

  bool get supportsSelfPickup => cart.restaurant?.providingSelfPickup ?? false;

  bool get hasAppliedCoupon =>
      cart.couponCode != null && cart.couponCode!.isNotEmpty;

  String? get effectiveTipAmount {
    if (isEmpty || isSelfPickup) return null;
    if (showCustomTipField) {
      final custom = customTipInput.trim();
      return custom.isEmpty ? null : custom;
    }
    return selectedTipAmount;
  }

  String? get deliveryType => isSelfPickup ? 'selfpick' : null;

  String? get paymentOrderType => isSelfPickup ? 'selfpick' : null;

  String get payableAmount => '₹ ${cart.grandTotal ?? cart.subTotal ?? '0'}';

  /// Checkout gate before payment (Android place-order pre-checks).
  String? get checkoutBlockReason {
    if (isEmpty) return 'Your cart is empty';
    if (!isSelfPickup) {
      final addressId = deliveryLocation?.id;
      if (addressId == null || addressId.isEmpty) {
        return 'Please add a delivery address';
      }
    }
    return null;
  }

  CartState copyWith({
    CartStatus? status,
    CartEntity? cart,
    DeliveryLocationEntity? deliveryLocation,
    String? couponCodeInput,
    String? pendingCouponCode,
    bool? isSelfPickup,
    String? selectedTipAmount,
    String? customTipInput,
    bool? showCustomTipField,
    List<String>? tipAmounts,
    String? errorMessage,
    bool clearError = false,
    bool clearPendingCoupon = false,
    bool clearSelectedTip = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      couponCodeInput: couponCodeInput ?? this.couponCodeInput,
      pendingCouponCode: clearPendingCoupon
          ? null
          : (pendingCouponCode ?? this.pendingCouponCode),
      isSelfPickup: isSelfPickup ?? this.isSelfPickup,
      selectedTipAmount: clearSelectedTip
          ? null
          : (selectedTipAmount ?? this.selectedTipAmount),
      customTipInput: clearSelectedTip
          ? ''
          : (customTipInput ?? this.customTipInput),
      showCustomTipField: showCustomTipField ?? this.showCustomTipField,
      tipAmounts: tipAmounts ?? this.tipAmounts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        cart,
        deliveryLocation,
        couponCodeInput,
        pendingCouponCode,
        isSelfPickup,
        selectedTipAmount,
        customTipInput,
        showCustomTipField,
        tipAmounts,
        errorMessage,
      ];
}
