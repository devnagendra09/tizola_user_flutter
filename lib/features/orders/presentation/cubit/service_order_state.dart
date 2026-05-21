import 'package:equatable/equatable.dart';

import '../../domain/entities/service_order_entity.dart';

enum ServiceOrderStatus { initial, loading, loaded, failure }

class ServiceOrderState extends Equatable {
  const ServiceOrderState({
    this.status = ServiceOrderStatus.initial,
    this.order,
    this.errorMessage,
  });

  final ServiceOrderStatus status;
  final ServiceOrderEntity? order;
  final String? errorMessage;

  ServiceOrderState copyWith({
    ServiceOrderStatus? status,
    ServiceOrderEntity? order,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ServiceOrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}
