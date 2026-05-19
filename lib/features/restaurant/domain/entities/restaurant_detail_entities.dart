import 'package:equatable/equatable.dart';

class StoreBannerEntity extends Equatable {
  const StoreBannerEntity({required this.id, required this.image});

  final String id;
  final String image;

  @override
  List<Object?> get props => [id, image];
}

class RestaurantDetailEntity extends Equatable {
  const RestaurantDetailEntity({
    required this.name,
    this.isOpened,
    this.isFavourite = false,
    this.address,
    this.distance,
  });

  final String name;
  final String? isOpened;
  final bool isFavourite;
  final String? address;
  final String? distance;

  bool get isOpen => (isOpened ?? '').toLowerCase() == 'open';

  @override
  List<Object?> get props => [name, isOpened, isFavourite, address, distance];
}

class CartSummaryEntity extends Equatable {
  const CartSummaryEntity({
    this.subTotal,
    this.itemCount = 0,
  });

  final String? subTotal;
  final int itemCount;

  bool get hasItems => itemCount > 0;

  @override
  List<Object?> get props => [subTotal, itemCount];
}

class CartMutationResult extends Equatable {
  const CartMutationResult({
    required this.success,
    this.tempCartItemId,
    this.message,
    this.errType,
  });

  final bool success;
  final String? tempCartItemId;
  final String? message;
  final String? errType;

  @override
  List<Object?> get props => [success, tempCartItemId, message, errType];
}
