import 'package:equatable/equatable.dart';

import 'order_entity.dart';

class OrdersPageEntity extends Equatable {
  const OrdersPageEntity({
    required this.orders,
    required this.totalPages,
    this.emptyMessage,
  });

  final List<OrderEntity> orders;
  final int totalPages;
  final String? emptyMessage;

  @override
  List<Object?> get props => [orders, totalPages, emptyMessage];
}
