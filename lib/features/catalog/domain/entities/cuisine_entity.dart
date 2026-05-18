import 'package:equatable/equatable.dart';

class CuisineEntity extends Equatable {
  const CuisineEntity({
    required this.id,
    required this.name,
    this.image,
    this.restaurantCount,
    this.isOpened,
  });

  final String id;
  final String name;
  final String? image;
  final String? restaurantCount;
  final String? isOpened;

  bool get isOpen => (isOpened ?? '').toLowerCase().contains('open');

  @override
  List<Object?> get props => [id, name, image, restaurantCount, isOpened];
}
