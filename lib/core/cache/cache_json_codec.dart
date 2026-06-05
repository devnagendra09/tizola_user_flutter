import '../../features/cart/domain/entities/cart_entity.dart';
import '../../features/catalog/domain/entities/cuisine_entity.dart';
import '../../features/catalog/domain/entities/order_entity.dart';
import '../../features/catalog/domain/entities/restaurant_entity.dart';
import '../../features/catalog/domain/enums/restaurant_food_filter.dart';
import '../../features/home/domain/entities/home_banner_entity.dart';
import '../../features/home/presentation/cubit/home_state.dart';
import '../../features/location/domain/entities/delivery_location_entity.dart';
import '../../features/orders/presentation/cubit/orders_state.dart';

/// JSON maps for Hive — no code generation; works on Android + iOS.
abstract final class CacheJsonCodec {
  static Map<String, dynamic> restaurantToJson(RestaurantEntity r) => {
        'id': r.id,
        'name': r.name,
        'seoUrl': r.seoUrl,
        'imageUrl': r.imageUrl,
        'cuisineTypes': r.cuisineTypes,
        'estimateTime': r.estimateTime,
        'offer': r.offer,
        'isOpened': r.isOpened,
        'fromTime': r.fromTime,
        'toTime': r.toTime,
        'distance': r.distance,
        'address': r.address,
        'rating': r.rating,
        'minimumOrderAmount': r.minimumOrderAmount,
        'foodType': r.foodType.name,
        'isExclusive': r.isExclusive,
        'isFavourite': r.isFavourite,
      };

  static RestaurantEntity restaurantFromJson(Map<String, dynamic> json) {
    final foodType = FoodType.values.firstWhere(
      (e) => e.name == json['foodType']?.toString(),
      orElse: () => FoodType.both,
    );
    return RestaurantEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      seoUrl: json['seoUrl']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      cuisineTypes: json['cuisineTypes']?.toString(),
      estimateTime: json['estimateTime']?.toString(),
      offer: json['offer']?.toString(),
      isOpened: json['isOpened']?.toString(),
      fromTime: json['fromTime']?.toString(),
      toTime: json['toTime']?.toString(),
      distance: json['distance']?.toString(),
      address: json['address']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      minimumOrderAmount: json['minimumOrderAmount']?.toString(),
      foodType: foodType,
      isExclusive: json['isExclusive'] == true,
      isFavourite: json['isFavourite'] == true,
    );
  }

  static Map<String, dynamic> cuisineToJson(CuisineEntity c) => {
        'id': c.id,
        'name': c.name,
        'image': c.image,
        'restaurantCount': c.restaurantCount,
        'isOpened': c.isOpened,
      };

  static CuisineEntity cuisineFromJson(Map<String, dynamic> json) =>
      CuisineEntity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString(),
        restaurantCount: json['restaurantCount']?.toString(),
        isOpened: json['isOpened']?.toString(),
      );

  static Map<String, dynamic> bannerToJson(HomeBannerEntity b) => {
        'id': b.id,
        'promotionImage': b.promotionImage,
        'restaurantId': b.restaurantId,
        'restaurantName': b.restaurantName,
        'restaurantSeoUrl': b.restaurantSeoUrl,
      };

  static HomeBannerEntity bannerFromJson(Map<String, dynamic> json) =>
      HomeBannerEntity(
        id: json['id']?.toString() ?? '',
        promotionImage: json['promotionImage']?.toString(),
        restaurantId: json['restaurantId']?.toString(),
        restaurantName: json['restaurantName']?.toString(),
        restaurantSeoUrl: json['restaurantSeoUrl']?.toString(),
      );

  static Map<String, dynamic> sliderToJson(HomeSliderEntity s) => {
        'id': s.id,
        'image': s.image,
        'redirectionUrl': s.redirectionUrl,
      };

  static HomeSliderEntity sliderFromJson(Map<String, dynamic> json) =>
      HomeSliderEntity(
        id: json['id']?.toString() ?? '',
        image: json['image']?.toString(),
        redirectionUrl: json['redirectionUrl']?.toString(),
      );

  static Map<String, dynamic> homeStateToJson(HomeState state) => {
        'notificationMessage': state.notificationMessage,
        'couponBanners':
            state.couponBanners.map(bannerToJson).toList(growable: false),
        'sliders': state.sliders.map(sliderToJson).toList(growable: false),
        'cuisines': state.cuisines.map(cuisineToJson).toList(growable: false),
        'restaurants':
            state.restaurants.map(restaurantToJson).toList(growable: false),
        'foodFilter': state.foodFilter.name,
        'currentPage': state.currentPage,
        'totalPages': state.totalPages,
        'isStoreAvailable': state.isStoreAvailable,
        'cityImage': state.cityImage,
        'emptyMessage': state.emptyMessage,
        'customerCarePhone': state.customerCarePhone,
        'customerCareWhatsapp': state.customerCareWhatsapp,
        'openRestaurantCount': state.openRestaurantCount,
      };

  static HomeState homeStateFromJson(
    Map<String, dynamic> json,
    HomeState base,
  ) {
    final foodFilter = RestaurantFoodFilter.values.firstWhere(
      (e) => e.name == json['foodFilter']?.toString(),
      orElse: () => RestaurantFoodFilter.all,
    );
    final restaurants = (json['restaurants'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => restaurantFromJson(Map<String, dynamic>.from(e)))
        .toList();
    final cuisines = (json['cuisines'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => cuisineFromJson(Map<String, dynamic>.from(e)))
        .toList();
    final banners = (json['couponBanners'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => bannerFromJson(Map<String, dynamic>.from(e)))
        .toList();
    final sliders = (json['sliders'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => sliderFromJson(Map<String, dynamic>.from(e)))
        .toList();

    return base.copyWith(
      status: HomeStatus.loaded,
      notificationMessage: json['notificationMessage']?.toString(),
      couponBanners: banners,
      sliders: sliders,
      cuisines: cuisines,
      restaurants: restaurants,
      foodFilter: foodFilter,
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      isStoreAvailable: json['isStoreAvailable'] as bool? ?? true,
      cityImage: json['cityImage']?.toString(),
      emptyMessage: json['emptyMessage']?.toString(),
      customerCarePhone: json['customerCarePhone']?.toString(),
      customerCareWhatsapp: json['customerCareWhatsapp']?.toString(),
      openRestaurantCount: json['openRestaurantCount'] as int? ??
          restaurants.where((r) => r.isOpen).length,
      clearError: true,
    );
  }

  static Map<String, dynamic> orderToJson(OrderEntity o) => {
        'refId': o.refId,
        'restaurantName': o.restaurantName,
        'deliveryAddress': o.deliveryAddress,
        'paymentStatus': o.paymentStatus,
        'grandTotal': o.grandTotal,
        'serviceStatus': o.serviceStatus,
        'cartItemsText': o.cartItemsText,
        'displayImage': o.displayImage,
        'deliveryPersonName': o.deliveryPersonName,
        'deliveryPersonContact': o.deliveryPersonContact,
        'deliveryBoyImage': o.deliveryBoyImage,
        'isFeedbackProvided': o.isFeedbackProvided,
        'selfPickAccepted': o.selfPickAccepted,
      };

  static OrderEntity orderFromJson(Map<String, dynamic> json) => OrderEntity(
        refId: json['refId']?.toString() ?? '',
        restaurantName: json['restaurantName']?.toString() ?? '',
        deliveryAddress: json['deliveryAddress']?.toString(),
        paymentStatus: json['paymentStatus']?.toString(),
        grandTotal: json['grandTotal']?.toString(),
        serviceStatus: json['serviceStatus']?.toString(),
        cartItemsText: json['cartItemsText']?.toString(),
        displayImage: json['displayImage']?.toString(),
        deliveryPersonName: json['deliveryPersonName']?.toString(),
        deliveryPersonContact: json['deliveryPersonContact']?.toString(),
        deliveryBoyImage: json['deliveryBoyImage']?.toString(),
        isFeedbackProvided: json['isFeedbackProvided'] == true,
        selfPickAccepted: json['selfPickAccepted'] == true,
      );

  static Map<String, dynamic> ordersPageToJson({
    required List<OrderEntity> orders,
    required int totalPages,
    String? emptyMessage,
  }) =>
      {
        'orders': orders.map(orderToJson).toList(growable: false),
        'totalPages': totalPages,
        'emptyMessage': emptyMessage,
      };

  static Map<String, dynamic> deliveryLocationToJson(
    DeliveryLocationEntity loc,
  ) =>
      {
        'id': loc.id,
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'address': loc.address,
        'addressType': loc.addressType,
        'doorNo': loc.doorNo,
        'landmark': loc.landmark,
        'addressDescription': loc.addressDescription,
        'addressTypeText': loc.addressTypeText,
        'city': loc.city,
      };

  static DeliveryLocationEntity deliveryLocationFromJson(
    Map<String, dynamic> json,
  ) =>
      DeliveryLocationEntity(
        id: json['id']?.toString(),
        latitude: (json['latitude'] as num?)?.toDouble() ??
            double.tryParse(json['latitude']?.toString() ?? '') ??
            0,
        longitude: (json['longitude'] as num?)?.toDouble() ??
            double.tryParse(json['longitude']?.toString() ?? '') ??
            0,
        address: json['address']?.toString() ?? '',
        addressType: json['addressType']?.toString() ?? 'Home',
        doorNo: json['doorNo']?.toString(),
        landmark: json['landmark']?.toString(),
        addressDescription: json['addressDescription']?.toString(),
        addressTypeText: json['addressTypeText']?.toString(),
        city: json['city']?.toString(),
      );

  static Map<String, dynamic> cartItemToJson(CartItemEntity item) => {
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'applicablePrice': item.applicablePrice,
        'image': item.image,
        'optionsName': item.optionsName,
        'addonsNames': item.addonsNames,
      };

  static CartItemEntity cartItemFromJson(Map<String, dynamic> json) =>
      CartItemEntity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        quantity: json['quantity'] as int? ??
            int.tryParse(json['quantity']?.toString() ?? '') ??
            0,
        applicablePrice: (json['applicablePrice'] as num?)?.toDouble() ??
            double.tryParse(json['applicablePrice']?.toString() ?? '') ??
            0,
        image: json['image']?.toString(),
        optionsName: json['optionsName']?.toString(),
        addonsNames: json['addonsNames']?.toString(),
      );

  static Map<String, dynamic> cartToJson(CartEntity cart) => {
        'restaurant': cart.restaurant == null
            ? null
            : {
                'name': cart.restaurant!.name,
                'image': cart.restaurant!.image,
                'address': cart.restaurant!.address,
                'cuisineTypes': cart.restaurant!.cuisineTypes,
                'minimumOrderAmount': cart.restaurant!.minimumOrderAmount,
                'providingSelfPickup': cart.restaurant!.providingSelfPickup,
              },
        'items': cart.items.map(cartItemToJson).toList(growable: false),
        'taxes': cart.taxes
            .map(
              (t) => {'name': t.name, 'amount': t.amount},
            )
            .toList(growable: false),
        'subTotal': cart.subTotal,
        'couponCode': cart.couponCode,
        'appliedDiscountAmount': cart.appliedDiscountAmount,
        'appliedTaxAmount': cart.appliedTaxAmount,
        'appliedDeliveryCharge': cart.appliedDeliveryCharge,
        'appliedTipAmount': cart.appliedTipAmount,
        'promotionWalletAmount': cart.promotionWalletAmount,
        'grandTotal': cart.grandTotal,
        'couponDiscountMessage': cart.couponDiscountMessage,
        'hasCouponDiscount': cart.hasCouponDiscount,
        'restaurantId': cart.restaurantId,
        'deliveryAddress': cart.deliveryAddress,
      };

  static CartEntity cartFromJson(Map<String, dynamic> json) {
    final restaurantMap = json['restaurant'];
    CartRestaurantInfoEntity? restaurant;
    if (restaurantMap is Map) {
      final r = Map<String, dynamic>.from(restaurantMap);
      restaurant = CartRestaurantInfoEntity(
        name: r['name']?.toString() ?? '',
        image: r['image']?.toString(),
        address: r['address']?.toString(),
        cuisineTypes: r['cuisineTypes']?.toString(),
        minimumOrderAmount: r['minimumOrderAmount']?.toString(),
        providingSelfPickup: r['providingSelfPickup'] == true,
      );
    }

    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => cartItemFromJson(Map<String, dynamic>.from(e)))
        .toList();
    final taxes = (json['taxes'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map(
          (e) => CartTaxEntity(
            name: e['name']?.toString() ?? '',
            amount: e['amount']?.toString() ?? '',
          ),
        )
        .toList();

    return CartEntity(
      restaurant: restaurant,
      items: items,
      taxes: taxes,
      subTotal: json['subTotal']?.toString(),
      couponCode: json['couponCode']?.toString(),
      appliedDiscountAmount: json['appliedDiscountAmount']?.toString(),
      appliedTaxAmount: json['appliedTaxAmount']?.toString(),
      appliedDeliveryCharge: json['appliedDeliveryCharge']?.toString(),
      appliedTipAmount: json['appliedTipAmount']?.toString(),
      promotionWalletAmount: json['promotionWalletAmount']?.toString(),
      grandTotal: json['grandTotal']?.toString(),
      couponDiscountMessage: json['couponDiscountMessage']?.toString(),
      hasCouponDiscount: json['hasCouponDiscount'] == true,
      restaurantId: json['restaurantId']?.toString(),
      deliveryAddress: json['deliveryAddress']?.toString(),
    );
  }

  static OrdersState applyOrdersCache(
    OrdersState base,
    Map<String, dynamic> upcoming,
    Map<String, dynamic> past,
  ) {
    final upcomingOrders = (upcoming['orders'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => orderFromJson(Map<String, dynamic>.from(e)))
        .toList();
    final pastOrders = (past['orders'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => orderFromJson(Map<String, dynamic>.from(e)))
        .toList();

    return base.copyWith(
      status: OrdersStatus.loaded,
      upcomingOrders: upcomingOrders,
      pastOrders: pastOrders,
      upcomingPage: 1,
      pastPage: 1,
      upcomingTotalPages: upcoming['totalPages'] as int? ?? 1,
      pastTotalPages: past['totalPages'] as int? ?? 1,
      upcomingEmptyMessage: upcoming['emptyMessage']?.toString(),
      pastEmptyMessage: past['emptyMessage']?.toString(),
      clearError: true,
    );
  }
}
