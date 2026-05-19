import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../location/domain/repositories/location_repository.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._cartRepository, this._locationRepository)
      : super(
          CartState(
            deliveryLocation: _locationRepository.savedDeliveryLocation,
          ),
        );

  final CartRepository _cartRepository;
  final LocationRepository _locationRepository;

  Future<void> loadCart() async {
    emit(state.copyWith(status: CartStatus.loading, clearError: true));

    final addressId = state.deliveryLocation?.id;
    final result = await _cartRepository.fetchCart(addressId: addressId);

    if (result.isFailure) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }

    final cart = result.data ?? const CartEntity();
    emit(
      state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        couponCodeInput: cart.couponCode ?? '',
        clearError: true,
      ),
    );
  }

  Future<void> incrementItem(CartItemEntity item) async {
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    final result = await _cartRepository.updateItemQuantity(
      cartItemId: item.id,
      quantity: item.quantity + 1,
    );
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    await loadCart();
  }

  Future<void> decrementItem(CartItemEntity item) async {
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    final result = item.quantity <= 1
        ? await _cartRepository.removeItem(cartItemId: item.id)
        : await _cartRepository.updateItemQuantity(
            cartItemId: item.id,
            quantity: item.quantity - 1,
          );
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    await loadCart();
  }

  void setCouponCodeInput(String value) {
    emit(state.copyWith(couponCodeInput: value));
  }

  Future<void> applyCoupon() async {
    final code = state.couponCodeInput.trim();
    if (code.isEmpty) return;

    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    final result = await _cartRepository.fetchCart(
      couponCode: code,
      addressId: state.deliveryLocation?.id,
    );
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    final cart = result.data ?? const CartEntity();
    emit(
      state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        clearError: true,
      ),
    );
  }

  Future<void> removeCoupon() async {
    emit(state.copyWith(status: CartStatus.updating, clearError: true));
    final result = await _cartRepository.removeCouponCode();
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    emit(state.copyWith(couponCodeInput: ''));
    await loadCart();
  }

  Future<void> refreshDeliveryLocation() async {
    emit(
      state.copyWith(
        deliveryLocation: _locationRepository.savedDeliveryLocation,
      ),
    );
    final addressId = state.deliveryLocation?.id;
    if (addressId != null && addressId.isNotEmpty) {
      await _cartRepository.updateDeliveryLocation(addressId: addressId);
    }
    await loadCart();
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
