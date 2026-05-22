import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/orders_repository.dart';
import 'service_order_state.dart';

class ServiceOrderCubit extends Cubit<ServiceOrderState> {
  ServiceOrderCubit(this._repository) : super(const ServiceOrderState());

  final OrdersRepository _repository;

  Future<void> load(String refId, {bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(status: ServiceOrderStatus.loading, clearError: true));
    }

    final result = await _repository.fetchServiceOrderView(refId: refId);
    if (isClosed) return;

    if (result.isFailure) {
      emit(
        state.copyWith(
          status: ServiceOrderStatus.failure,
          errorMessage: result.failure?.message ?? 'Failed to load order',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ServiceOrderStatus.loaded,
        order: result.data,
        clearError: true,
      ),
    );
  }

  Future<String?> cancelOrder({
    required String refId,
    required String reason,
  }) async {
    final result = await _repository.cancelOrder(
      refId: refId,
      reason: reason,
    );
    if (isClosed) return null;
    if (result.isFailure) {
      return result.failure?.message ?? 'Failed to cancel order';
    }
    // Keep current UI mounted; full loading shimmer was disposing cancel timer.
    await load(refId, showLoading: false);
    return null;
  }
}
