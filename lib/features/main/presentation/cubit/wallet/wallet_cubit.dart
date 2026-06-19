import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/entities/wallet_add_result.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';

enum WalletStatus { initial, loading, loaded, processing }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance = '0/-',
    this.pendingCheckout,
    this.isBusy = false,
    this.errorMessage,
    this.successMessage,
  });

  final WalletStatus status;
  final String balance;
  final WalletAddResult? pendingCheckout;
  final bool isBusy;
  final String? errorMessage;
  final String? successMessage;

  WalletState copyWith({
    WalletStatus? status,
    String? balance,
    WalletAddResult? pendingCheckout,
    bool clearPendingCheckout = false,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      pendingCheckout: clearPendingCheckout
          ? null
          : (pendingCheckout ?? this.pendingCheckout),
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance,
        pendingCheckout,
        isBusy,
        errorMessage,
        successMessage,
      ];
}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletState());

  final AuthRepository _repository;

  Future<void> loadBalance() async {
    final showLoader = state.status != WalletStatus.loaded;
    if (showLoader) {
      emit(
        state.copyWith(
          status: WalletStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
    }

    final result = await _repository.fetchWalletBalance();
    if (isClosed) return;

    emit(
      state.copyWith(
        status: WalletStatus.loaded,
        balance: result.data ?? '0/-',
        clearError: true,
      ),
    );
  }

  Future<void> addMoney(String amount) async {
    emit(
      state.copyWith(
        isBusy: true,
        clearError: true,
        clearSuccess: true,
        clearPendingCheckout: true,
      ),
    );

    final result = await _repository.addWallet(amount: amount);
    if (isClosed) return;

    if (result.isFailure) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: result.failure?.message ?? 'Failed to add money',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isBusy: false,
        pendingCheckout: result.data,
      ),
    );
  }

  void clearPendingCheckout() {
    emit(state.copyWith(clearPendingCheckout: true));
  }

  Future<void> confirmPayment({
    required WalletAddResult checkout,
    required String paymentGatewayId,
  }) async {
    emit(
      state.copyWith(
        isBusy: true,
        clearError: true,
        clearSuccess: true,
        clearPendingCheckout: true,
      ),
    );

    final result = await _repository.updateWalletStatus(
      amount: checkout.amount,
      refId: checkout.refId,
      razorpayOrderId: checkout.razorpayOrderId,
      paymentGatewayId: paymentGatewayId,
    );
    if (isClosed) return;

    if (result.isFailure) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: result.failure?.message ?? 'Payment update failed',
        ),
      );
      return;
    }

    final balanceResult = await _repository.fetchWalletBalance();
    if (isClosed) return;

    emit(
      state.copyWith(
        status: WalletStatus.loaded,
        isBusy: false,
        balance: balanceResult.data ?? state.balance,
        successMessage: result.data,
      ),
    );
  }

  void onPaymentCancelled() {
    emit(
      state.copyWith(
        isBusy: false,
        clearPendingCheckout: true,
      ),
    );
  }
}
