import 'package:equatable/equatable.dart';

class MenuAddonEntity extends Equatable {
  const MenuAddonEntity({
    required this.id,
    required this.name,
    required this.price,
    this.isMandatory = false,
  });

  final String id;
  final String name;
  final double price;
  final bool isMandatory;

  @override
  List<Object?> get props => [id, name, price, isMandatory];
}

class MenuOptionEntity extends Equatable {
  const MenuOptionEntity({
    required this.id,
    required this.name,
    required this.applicablePrice,
    this.actualPrice,
  });

  final String id;
  final String name;
  final double applicablePrice;
  final double? actualPrice;

  @override
  List<Object?> get props => [id, name, applicablePrice, actualPrice];
}

class MenuItemEntity extends Equatable {
  const MenuItemEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.image,
    this.foodType,
    this.actualPrice = 0,
    this.applicablePrice = 0,
    this.available = true,
    this.isRecommended = false,
    this.isRestaurantOpen = true,
    this.addOns = const [],
    this.options = const [],
    this.tempCartItemId,
    this.quantity = 0,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final String? image;
  final String? foodType;
  final double actualPrice;
  final double applicablePrice;
  final bool available;
  final bool isRecommended;
  final bool isRestaurantOpen;
  final List<MenuAddonEntity> addOns;
  final List<MenuOptionEntity> options;
  final String? tempCartItemId;
  final int quantity;

  bool get hasCustomizations => addOns.isNotEmpty || options.isNotEmpty;
  bool get isSoldOut => !available;
  bool get isVeg => (foodType ?? '').toLowerCase() == 'veg';
  bool get inCart => quantity > 0 && tempCartItemId != null;

  MenuItemEntity copyWith({
    String? tempCartItemId,
    int? quantity,
    bool clearTempCartItemId = false,
  }) {
    return MenuItemEntity(
      id: id,
      restaurantId: restaurantId,
      name: name,
      description: description,
      image: image,
      foodType: foodType,
      actualPrice: actualPrice,
      applicablePrice: applicablePrice,
      available: available,
      isRecommended: isRecommended,
      isRestaurantOpen: isRestaurantOpen,
      addOns: addOns,
      options: options,
      tempCartItemId:
          clearTempCartItemId ? null : (tempCartItemId ?? this.tempCartItemId),
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        name,
        description,
        image,
        foodType,
        actualPrice,
        applicablePrice,
        available,
        isRecommended,
        isRestaurantOpen,
        addOns,
        options,
        tempCartItemId,
        quantity,
      ];
}

class MenuCategoryEntity extends Equatable {
  const MenuCategoryEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.items = const [],
  });

  final String id;
  final String restaurantId;
  final String name;
  final List<MenuItemEntity> items;

  MenuCategoryEntity copyWith({List<MenuItemEntity>? items}) {
    return MenuCategoryEntity(
      id: id,
      restaurantId: restaurantId,
      name: name,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, restaurantId, name, items];
}
