import 'package:equatable/equatable.dart';

import '../../../location/domain/entities/delivery_location_entity.dart';

class MainState extends Equatable {
  const MainState({
    this.currentIndex = 0,
    this.showLoginDialog = false,
    this.deliveryLocation,
  });

  final int currentIndex;
  final bool showLoginDialog;
  final DeliveryLocationEntity? deliveryLocation;

  MainState copyWith({
    int? currentIndex,
    bool? showLoginDialog,
    DeliveryLocationEntity? deliveryLocation,
  }) {
    return MainState(
      currentIndex: currentIndex ?? this.currentIndex,
      showLoginDialog: showLoginDialog ?? this.showLoginDialog,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
    );
  }

  @override
  List<Object?> get props =>
      [currentIndex, showLoginDialog, deliveryLocation];
}
