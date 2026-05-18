import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/order_entity.dart';

enum OrdersStatus { initial, loading, loaded, failure }

enum OrderTab { upcoming, past }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.selectedTab = OrderTab.upcoming,
    this.upcomingOrders = const [],
    this.pastOrders = const [],
    this.upcomingPage = 1,
    this.pastPage = 1,
    this.upcomingTotalPages = 1,
    this.pastTotalPages = 1,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final OrdersStatus status;
  final OrderTab selectedTab;
  final List<OrderEntity> upcomingOrders;
  final List<OrderEntity> pastOrders;
  final int upcomingPage;
  final int pastPage;
  final int upcomingTotalPages;
  final int pastTotalPages;
  final bool isLoadingMore;
  final String? errorMessage;

  List<OrderEntity> get currentOrders =>
      selectedTab == OrderTab.upcoming ? upcomingOrders : pastOrders;

  bool get hasMore => selectedTab == OrderTab.upcoming
      ? upcomingPage < upcomingTotalPages
      : pastPage < pastTotalPages;

  OrdersState copyWith({
    OrdersStatus? status,
    OrderTab? selectedTab,
    List<OrderEntity>? upcomingOrders,
    List<OrderEntity>? pastOrders,
    int? upcomingPage,
    int? pastPage,
    int? upcomingTotalPages,
    int? pastTotalPages,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      upcomingOrders: upcomingOrders ?? this.upcomingOrders,
      pastOrders: pastOrders ?? this.pastOrders,
      upcomingPage: upcomingPage ?? this.upcomingPage,
      pastPage: pastPage ?? this.pastPage,
      upcomingTotalPages: upcomingTotalPages ?? this.upcomingTotalPages,
      pastTotalPages: pastTotalPages ?? this.pastTotalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        upcomingOrders,
        pastOrders,
        upcomingPage,
        pastPage,
        upcomingTotalPages,
        pastTotalPages,
        isLoadingMore,
        errorMessage,
      ];
}
