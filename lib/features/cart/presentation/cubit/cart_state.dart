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
    this.errorMessage,
  });

  final CartStatus status;
  final CartEntity cart;
  final DeliveryLocationEntity? deliveryLocation;
  final String couponCodeInput;
  final String? errorMessage;

  bool get isEmpty => cart.isEmpty;

  String get payableAmount => '₹ ${cart.grandTotal ?? cart.subTotal ?? '0'}';

  CartState copyWith({
    CartStatus? status,
    CartEntity? cart,
    DeliveryLocationEntity? deliveryLocation,
    String? couponCodeInput,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      couponCodeInput: couponCodeInput ?? this.couponCodeInput,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, cart, deliveryLocation, couponCodeInput, errorMessage];
}
