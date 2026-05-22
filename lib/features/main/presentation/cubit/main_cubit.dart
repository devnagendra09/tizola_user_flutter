import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../location/domain/repositories/location_repository.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit(
    this._authRepository,
    this._locationRepository,
    this._catalogRepository,
    this._cartRepository,
  ) : super(const MainState()) {

    loadDeliveryLocation();
    refreshInProgressOrder();
    refreshCartBadge();
  }

  final AuthRepository _authRepository;
  final LocationRepository _locationRepository;
  final CatalogRepository _catalogRepository;
  final CartRepository _cartRepository;

  void loadDeliveryLocation() {
    emit(
      state.copyWith(
        deliveryLocation: _locationRepository.savedDeliveryLocation,
      ),
    );
  }

  Future<void> onTabSelected(int index) async {
    if (index == 2 || index == 3) {
      final session = await _authRepository.getSession();
      if (session.isSuccess && session.data!.isLoggedIn) {
        emit(state.copyWith(currentIndex: index, showLoginDialog: false));
      } else {
        emit(state.copyWith(showLoginDialog: true));
      }
      return;
    }
    emit(state.copyWith(currentIndex: index, showLoginDialog: false));
    if (index == 0) {
      refreshCartBadge();
    }
  }
  void dismissLoginDialog() {
    emit(state.copyWith(showLoginDialog: false));
  }
  void selectTab(int index) {
    emit(state.copyWith(currentIndex: index, showLoginDialog: false));
    if (index == 0) {
      refreshCartBadge();
    }
  }

  /// Android `MainActivity.fetchCart` on resume — toolbar cart badge.
  Future<void> refreshCartBadge() async {
    final session = await _authRepository.getSession();
    if (!session.isSuccess || session.data == null || !session.data!.isLoggedIn) {
      if (!isClosed) emit(state.copyWith(cartItemCount: 0));
      return;
    }

    final result = await _cartRepository.fetchCartItemCount();
    if (isClosed) return;

    final count = result.isSuccess ? (result.data ?? 0) : 0;
    emit(state.copyWith(cartItemCount: count));
  }
  Future<void> refreshInProgressOrder() async {
    final session = await _authRepository.getSession();
    if (!session.isSuccess || session.data == null || !session.data!.isLoggedIn) {
      if (!isClosed) emit(state.copyWith(clearInProgressOrder: true));
      return;
    }
    final result = await _catalogRepository.checkInProgressOrder();
    if (isClosed) return;

    if (result.isSuccess) {
      final order = result.data;
      if (order == null) {
        emit(state.copyWith(clearInProgressOrder: true));
      } else {
        emit(state.copyWith(inProgressOrder: order));
      }
    }
  }
  /// After placing an order the API may lag; retry like Android `onResume` polling.
  Future<void> refreshInProgressOrderAfterCheckout() async {
    const delays = [
      Duration.zero,
      Duration(milliseconds: 600),
      Duration(milliseconds: 1500),
    ];
    for (final delay in delays) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (isClosed) return;
      await refreshInProgressOrder();
      if (state.inProgressOrder != null) {
        await refreshCartBadge();
        return;
      }
    }
    await refreshCartBadge();
  }
}
