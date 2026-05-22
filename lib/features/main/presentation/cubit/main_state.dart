import 'package:equatable/equatable.dart';

import '../../../location/domain/entities/delivery_location_entity.dart';
import '../../domain/entities/in_progress_order_entity.dart';

class MainState extends Equatable {
  const MainState({
    this.currentIndex = 0,
    this.showLoginDialog = false,
    this.deliveryLocation,
    this.inProgressOrder,
    this.cartItemCount = 0,
  });

  final int currentIndex;
  final bool showLoginDialog;
  final DeliveryLocationEntity? deliveryLocation;
  final InProgressOrderEntity? inProgressOrder;
  final int cartItemCount;

  MainState copyWith({
    int? currentIndex,
    bool? showLoginDialog,
    DeliveryLocationEntity? deliveryLocation,
    InProgressOrderEntity? inProgressOrder,
    int? cartItemCount,
    bool clearInProgressOrder = false,
  }) {
    return MainState(
      currentIndex: currentIndex ?? this.currentIndex,
      showLoginDialog: showLoginDialog ?? this.showLoginDialog,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      inProgressOrder: clearInProgressOrder
          ? null
          : (inProgressOrder ?? this.inProgressOrder),
      cartItemCount: cartItemCount ?? this.cartItemCount,
    );
  }

  @override
  List<Object?> get props => [
        currentIndex,
        showLoginDialog,
        deliveryLocation,
        inProgressOrder,
        cartItemCount,
      ];
}
