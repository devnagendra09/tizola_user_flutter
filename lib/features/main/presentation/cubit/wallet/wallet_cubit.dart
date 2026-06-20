import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/entities/wallet_add_result.dart';
import '../../../../auth/domain/entities/wallet_transaction_entity.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';

enum WalletStatus { initial, loading, loaded, processing }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance = '0/-',
    this.transactions = const [],
    this.transactionsPage = 1,
    this.transactionsTotalPages = 1,
    this.transactionsEmptyMessage = '',
    this.isLoadingMoreTransactions = false,
    this.pendingCheckout,
    this.isBusy = false,
    this.errorMessage,
    this.successMessage,
  });

  final WalletStatus status;
  final String balance;
  final List<WalletTransactionEntity> transactions;
  final int transactionsPage;
  final int transactionsTotalPages;
  final String transactionsEmptyMessage;
  final bool isLoadingMoreTransactions;
  final WalletAddResult? pendingCheckout;
  final bool isBusy;
  final String? errorMessage;
  final String? successMessage;

  bool get hasMoreTransactions => transactionsPage < transactionsTotalPages;

  WalletState copyWith({
    WalletStatus? status,
    String? balance,
    List<WalletTransactionEntity>? transactions,
    int? transactionsPage,
    int? transactionsTotalPages,
    String? transactionsEmptyMessage,
    bool? isLoadingMoreTransactions,
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
      transactions: transactions ?? this.transactions,
      transactionsPage: transactionsPage ?? this.transactionsPage,
      transactionsTotalPages:
          transactionsTotalPages ?? this.transactionsTotalPages,
      transactionsEmptyMessage:
          transactionsEmptyMessage ?? this.transactionsEmptyMessage,
      isLoadingMoreTransactions:
          isLoadingMoreTransactions ?? this.isLoadingMoreTransactions,
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
        transactions,
        transactionsPage,
        transactionsTotalPages,
        transactionsEmptyMessage,
        isLoadingMoreTransactions,
        pendingCheckout,
        isBusy,
        errorMessage,
        successMessage,
      ];
}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletState());

  final AuthRepository _repository;

  Future<void> loadWallet({bool force = false}) async {
    final showLoader = force || state.status != WalletStatus.loaded;
    if (showLoader) {
      emit(
        state.copyWith(
          status: WalletStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
    }

    final result = await _repository.fetchWalletTransactions(page: 1);
    if (isClosed) return;

    if (result.isFailure) {
      if (showLoader) {
        emit(
          state.copyWith(
            status: WalletStatus.loaded,
            errorMessage: result.failure?.message,
          ),
        );
      }
      return;
    }

    final data = result.data!;
    emit(
      state.copyWith(
        status: WalletStatus.loaded,
        balance: data.walletDisplay,
        transactions: data.transactions,
        transactionsPage: 1,
        transactionsTotalPages: data.totalPages,
        transactionsEmptyMessage: data.emptyMessage,
        clearError: true,
      ),
    );
  }

  Future<void> loadMoreTransactions() async {
    if (state.isLoadingMoreTransactions || !state.hasMoreTransactions) return;

    emit(state.copyWith(isLoadingMoreTransactions: true));
    final nextPage = state.transactionsPage + 1;

    final result = await _repository.fetchWalletTransactions(page: nextPage);
    if (isClosed) return;

    if (result.isFailure) {
      emit(
        state.copyWith(
          isLoadingMoreTransactions: false,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }

    final data = result.data!;
    emit(
      state.copyWith(
        transactions: [...state.transactions, ...data.transactions],
        transactionsPage: nextPage,
        transactionsTotalPages: data.totalPages,
        isLoadingMoreTransactions: false,
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

    await loadWallet(force: false);
    if (isClosed) return;

    emit(
      state.copyWith(
        isBusy: false,
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
