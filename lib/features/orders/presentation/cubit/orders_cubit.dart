import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/hive_local_cache.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository, this._hiveCache) : super(const OrdersState());

  final CatalogRepository _repository;
  final HiveLocalCache _hiveCache;

  Future<void> _restoreFromDiskIfNeeded() async {
    if (state.upcomingOrders.isNotEmpty || state.pastOrders.isNotEmpty) {
      return;
    }
    final cached = _hiveCache.readOrdersState(state);
    if (cached != null) emit(cached);
  }

  Future<void> loadOrdersIfNeeded({OrderTab? tab}) async {
    await _restoreFromDiskIfNeeded();

    final target = tab ?? state.selectedTab;
    final hasData = target == OrderTab.upcoming
        ? state.upcomingOrders.isNotEmpty
        : state.pastOrders.isNotEmpty;
    if (hasData && state.status == OrdersStatus.loaded) {
      if (tab != null && tab != state.selectedTab) {
        emit(state.copyWith(selectedTab: tab));
      }
      return;
    }
    await loadOrders(tab: tab);
  }

  Future<void> loadOrders({OrderTab? tab, bool force = false}) async {
    final target = tab ?? state.selectedTab;
    if (!force) {
      await _restoreFromDiskIfNeeded();
    }

    final hasData = target == OrderTab.upcoming
        ? state.upcomingOrders.isNotEmpty
        : state.pastOrders.isNotEmpty;

    if (!hasData) {
      emit(
        state.copyWith(
          status: OrdersStatus.loading,
          selectedTab: target,
          clearError: true,
        ),
      );
    } else {
      emit(state.copyWith(selectedTab: target, clearError: true));
    }

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
        await _hiveCache.saveOrdersUpcoming(
          orders: data.orders,
          totalPages: data.totalPages,
          emptyMessage: data.emptyMessage,
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
        await _hiveCache.saveOrdersPast(
          orders: data.orders,
          totalPages: data.totalPages,
          emptyMessage: data.emptyMessage,
        );
      }
    } else if (!hasData) {
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
