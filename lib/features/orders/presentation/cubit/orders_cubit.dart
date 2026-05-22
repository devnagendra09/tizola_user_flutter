import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/repositories/catalog_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository) : super(const OrdersState());

  final CatalogRepository _repository;

  Future<void> loadOrders({OrderTab? tab}) async {
    final target = tab ?? state.selectedTab;
    emit(
      state.copyWith(
        status: OrdersStatus.loading,
        selectedTab: target,
        clearError: true,
      ),
    );

    final type = target == OrderTab.upcoming ? 'Upcoming' : 'Past';
    final result = await _repository.getOrders(type: type, page: 1);

    if (result.isSuccess) {
      final data = result.data!;
      if (target == OrderTab.upcoming) {
        emit(
          state.copyWith(
            status: OrdersStatus.loaded,
            upcomingOrders: data.orders,
            upcomingPage: 1,
            upcomingTotalPages: data.totalPages,
            upcomingEmptyMessage: data.emptyMessage,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: OrdersStatus.loaded,
            pastOrders: data.orders,
            pastPage: 1,
            pastTotalPages: data.totalPages,
            pastEmptyMessage: data.emptyMessage,
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
    }
  }

  Future<void> switchTab(OrderTab tab) async {
    if (tab == state.selectedTab &&
        (tab == OrderTab.upcoming
            ? state.upcomingOrders.isNotEmpty
            : state.pastOrders.isNotEmpty)) {
      emit(state.copyWith(selectedTab: tab));
      return;
    }
    await loadOrders(tab: tab);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final isUpcoming = state.selectedTab == OrderTab.upcoming;
    final nextPage =
        isUpcoming ? state.upcomingPage + 1 : state.pastPage + 1;
    final type = isUpcoming ? 'Upcoming' : 'Past';

    final result = await _repository.getOrders(type: type, page: nextPage);

    if (result.isFailure) {
      emit(state.copyWith(isLoadingMore: false));
      return;
    }

    final data = result.data!;
    if (isUpcoming) {
      emit(
        state.copyWith(
          upcomingOrders: [...state.upcomingOrders, ...data.orders],
          upcomingPage: nextPage,
          upcomingTotalPages: data.totalPages,
          isLoadingMore: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          pastOrders: [...state.pastOrders, ...data.orders],
          pastPage: nextPage,
          pastTotalPages: data.totalPages,
          isLoadingMore: false,
        ),
      );
    }
  }
}
