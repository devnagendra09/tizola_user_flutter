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

  /// [tipAmountOverride] — use `'0'` to clear tip on server (Android sends `""` / `"0"`).
  Future<void> loadCart({String? tipAmountOverride}) async {
    final hadItems = !state.isEmpty;
    emit(
      state.copyWith(
        status: hadItems ? CartStatus.updating : CartStatus.loading,
        clearError: true,
      ),
    );

    if (!state.isSelfPickup && state.tipAmounts.isEmpty) {
      await _loadTipAmounts();
    }

    final couponToApply = state.pendingCouponCode ?? state.couponCodeInput.trim();
    final tipForApi = tipAmountOverride ?? state.effectiveTipAmount;
    final result = await _cartRepository.fetchCart(
      couponCode: couponToApply.isEmpty ? null : couponToApply,
      addressId: state.isSelfPickup ? null : state.deliveryLocation?.id,
      tipAmount: hadItems ? tipForApi : null,
      deliveryType: state.deliveryType,
    );

    if (result.isFailure) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          errorMessage: result.failure?.message,
          clearPendingCoupon: true,
        ),
      );
      return;
    }

    final cart = result.data ?? const CartEntity();
    if (cart.isEmpty) {
      emit(_emptyCartState());
      return;
    }

    final supportsPickup = cart.restaurant?.providingSelfPickup ?? false;

    emit(
      state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        couponCodeInput: cart.couponCode ?? '',
        clearPendingCoupon: true,
        clearError: true,
        isSelfPickup: supportsPickup && state.isSelfPickup,
      ),
    );
  }

  CartState _emptyCartState() {
    return CartState(
      status: CartStatus.loaded,
      cart: const CartEntity(),
      deliveryLocation: state.deliveryLocation,
      couponCodeInput: '',
      isSelfPickup: false,
      showCustomTipField: false,
      customTipInput: '',
      tipAmounts: state.tipAmounts,
    );
  }

  Future<void> _loadTipAmounts() async {
    final result = await _cartRepository.fetchTipAmounts();
    if (result.isSuccess && !isClosed) {
      emit(state.copyWith(tipAmounts: result.data ?? []));
    }
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

    if (item.quantity <= 1 && state.cart.items.length <= 1) {
      emit(_emptyCartState().copyWith(status: CartStatus.updating));
    }

    await loadCart();
  }

  Future<void> clearTip() async {
    if (state.isEmpty) return;
    emit(
      state.copyWith(
        clearSelectedTip: true,
        customTipInput: '',
        showCustomTipField: false,
      ),
    );
    await loadCart(tipAmountOverride: '0');
  }

  void setCouponCodeInput(String value) {
    emit(state.copyWith(couponCodeInput: value));
  }

  void selectCouponFromOffers(String code) {
    emit(state.copyWith(pendingCouponCode: code, couponCodeInput: code));
  }

  Future<void> applyCoupon() async {
    final code = state.couponCodeInput.trim();
    if (code.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter coupon code!'));
      return;
    }
    emit(state.copyWith(pendingCouponCode: code));
    await loadCart();
  }

  Future<void> removeCoupon({bool openOffersAfter = false}) async {
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
    emit(
      state.copyWith(
        couponCodeInput: '',
        clearPendingCoupon: true,
      ),
    );
    await loadCart();
    if (openOffersAfter) {
      emit(state.copyWith(status: CartStatus.loaded));
    }
  }

  Future<void> refreshDeliveryLocation() async {
    emit(
      state.copyWith(
        deliveryLocation: _locationRepository.savedDeliveryLocation,
      ),
    );
    final addressId = state.deliveryLocation?.id;
    if (addressId != null && addressId.isNotEmpty) {
      final result = await _cartRepository.updateDeliveryLocation(
        addressId: addressId,
      );
      if (result.isFailure) {
        emit(state.copyWith(errorMessage: result.failure?.message));
        return;
      }
    }
    await loadCart();
  }

  /// User tapped self-pick checkbox ON — show confirmation in UI before calling this.
  Future<void> confirmSelfPickup() async {
    emit(
      state.copyWith(
        isSelfPickup: true,
        clearSelectedTip: true,
        customTipInput: '',
        showCustomTipField: false,
      ),
    );
    await loadCart();
  }

  void cancelSelfPickup() {
    emit(
      state.copyWith(
        isSelfPickup: false,
        clearSelectedTip: true,
        customTipInput: '',
        showCustomTipField: false,
      ),
    );
    loadCart();
  }

  void disableSelfPickupOnExit() {
    if (state.isSelfPickup) {
      emit(state.copyWith(isSelfPickup: false));
    }
  }

  Future<void> selectTipAmount(String? amount) async {
    final clearing = amount == null || amount.isEmpty;
    emit(
      state.copyWith(
        clearSelectedTip: clearing,
        selectedTipAmount: clearing ? null : amount,
        showCustomTipField: false,
        customTipInput: '',
        clearError: true,
      ),
    );
    await loadCart(tipAmountOverride: clearing ? '0' : null);
  }

  void toggleCustomTipField(bool show) {
    emit(
      state.copyWith(
        showCustomTipField: show,
        clearSelectedTip: show,
        customTipInput: show ? state.customTipInput : '',
      ),
    );
    if (!show) {
      loadCart(tipAmountOverride: '0');
    }
  }

  void setCustomTipInput(String value) {
    emit(state.copyWith(customTipInput: value));
  }

  Future<bool> applyCustomTipIfValid() async {
    final text = state.customTipInput.trim();
    if (text.isEmpty) {
      await clearTip();
      return true;
    }
    final amount = double.tryParse(text);
    if (amount == null) return false;
    if (amount > 1000) {
      emit(
        state.copyWith(
          errorMessage:
              'Tip amount is too high. Please enter an amount up to ₹1000.',
          customTipInput: '',
          clearSelectedTip: true,
        ),
      );
      await loadCart(tipAmountOverride: '0');
      return false;
    }
    emit(
      state.copyWith(
        selectedTipAmount: text,
        showCustomTipField: true,
      ),
    );
    await loadCart();
    return true;
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
