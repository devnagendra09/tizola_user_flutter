import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/restaurant_about_entity.dart';
import '../../domain/entities/restaurant_detail_entities.dart';
import '../../domain/entities/restaurant_review_entity.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';

abstract class RestaurantRemoteDataSource {
  Future<RestaurantDetailEntity> getRestaurantDetail({required String seoUrl});
  Future<List<StoreBannerEntity>> getStoreBanners({required String seoUrl});
  Future<List<MenuCategoryEntity>> getMenu({
    required String seoUrl,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
  });
  Future<CartSummaryEntity> getCartSummary();
  Future<CartMutationResult> addToCart({
    required String restaurantId,
    required String foodItemId,
    String? optionId,
    List<String> addonIds = const [],
  });
  Future<CartMutationResult> updateCartQuantity({
    required String tempCartItemId,
    required int quantity,
  });
  Future<void> removeFromCart({required String tempCartItemId});
  Future<void> clearCart();
  Future<void> toggleFavourite({required String seoUrl});

  Future<RestaurantAboutEntity> getAbout({required String seoUrl});

  Future<({List<RestaurantReviewEntity> items, int totalPages})> getReviews({
    required String seoUrl,
    required int page,
  });
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  RestaurantRemoteDataSourceImpl(
    this._client,
    this._paramsBuilder,
    this._appLocal,
  );

  final ApiClient _client;
  final ApiParamsBuilder _paramsBuilder;
  final AppLocalDataSource _appLocal;

  @override
  Future<RestaurantDetailEntity> getRestaurantDetail({
    required String seoUrl,
  }) async {
    final params = _paramsBuilder.baseParams();
    params['seo_url'] = seoUrl;

    final response = await _client.post('restaurant_data', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    return RestaurantDetailEntity(
      name: data['restaurant_name']?.toString() ?? '',
      isOpened: data['is_opened']?.toString(),
      isFavourite: (data['is_favourite']?.toString() ?? '0') == '1',
      address: data['display_address']?.toString(),
      distance: data['distance']?.toString(),
    );
  }

  @override
  Future<List<StoreBannerEntity>> getStoreBanners({
    required String seoUrl,
  }) async {
    final params = _paramsBuilder.baseParams();
    params['seo_url'] = seoUrl;

    final response = await _client.post('store_banners', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return const [];

    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) {
          final map = e as Map<String, dynamic>;
          final image = map['image']?.toString() ?? '';
          if (image.isEmpty) return null;
          return StoreBannerEntity(
            id: map['id']?.toString() ?? '',
            image: image,
          );
        })
        .whereType<StoreBannerEntity>()
        .toList();
  }

  @override
  Future<List<MenuCategoryEntity>> getMenu({
    required String seoUrl,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['seo_url'] = seoUrl;
    params['m_sess_cart_id'] = _appLocal.sessionCartId;
    params['food_type'] = switch (foodFilter) {
      RestaurantFoodFilter.veg => 'Veg',
      RestaurantFoodFilter.nonVeg => 'Non Veg',
      RestaurantFoodFilter.all => '',
    };

    final response = await _client.post('restaurant_data/menu', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final categories = <MenuCategoryEntity>[];
    final recommended = <MenuItemEntity>[];
    final data = json['data'] as List<dynamic>? ?? [];

    for (final entry in data) {
      final map = entry as Map<String, dynamic>;
      final items = _parseFoodItems(map['food_items'] as List<dynamic>? ?? []);
      for (final item in items) {
        if (item.isRecommended) recommended.add(item);
      }
      categories.add(
        MenuCategoryEntity(
          id: map['id']?.toString() ?? '',
          restaurantId: map['restaurants_id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          items: items,
        ),
      );
    }

    if (recommended.isNotEmpty) {
      categories.insert(
        0,
        MenuCategoryEntity(
          id: 'recommended',
          restaurantId: recommended.first.restaurantId,
          name: 'Recommended',
          items: recommended,
        ),
      );
    }

    return categories;
  }

  @override
  Future<CartSummaryEntity> getCartSummary() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['m_sess_cart_id'] = _appLocal.sessionCartId;

    final response = await _client.post('cart', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return const CartSummaryEntity();
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final cartItems = data['cart_items'] as List<dynamic>? ?? [];
    if (cartItems.isEmpty) {
      return const CartSummaryEntity();
    }

    var qty = 0;
    for (final item in cartItems) {
      qty += int.tryParse((item as Map<String, dynamic>)['qty']?.toString() ?? '') ??
          0;
    }

    return CartSummaryEntity(
      subTotal: data['sub_total']?.toString(),
      itemCount: qty,
    );
  }

  @override
  Future<CartMutationResult> addToCart({
    required String restaurantId,
    required String foodItemId,
    String? optionId,
    List<String> addonIds = const [],
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['restaurants_id'] = restaurantId;
    params['restaurant_food_items_id'] = foodItemId;
    params['m_sess_cart_id'] = _appLocal.sessionCartId;
    if (optionId != null && optionId.isNotEmpty) {
      params['restaurant_food_item_options_id'] = optionId;
    }
    if (addonIds.isNotEmpty) {
      params['restaurant_food_item_addons_id'] = addonIds.join(', ');
    }

    final response = await _client.post('cart/add', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return CartMutationResult(
        success: false,
        message: ApiResponseParser.message(json),
        errType: json['err_type']?.toString(),
      );
    }

    return CartMutationResult(
      success: true,
      tempCartItemId: json['temp_cart_items_id']?.toString(),
    );
  }

  @override
  Future<CartMutationResult> updateCartQuantity({
    required String tempCartItemId,
    required int quantity,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['id'] = tempCartItemId;
    params['qty'] = quantity.toString();
    params['m_sess_cart_id'] = _appLocal.sessionCartId;

    final response = await _client.post('cart/update_qty', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return CartMutationResult(
        success: false,
        message: ApiResponseParser.message(json),
        errType: json['err_type']?.toString(),
      );
    }
    return const CartMutationResult(success: true);
  }

  @override
  Future<void> removeFromCart({required String tempCartItemId}) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['id'] = tempCartItemId;
    params['m_sess_cart_id'] = _appLocal.sessionCartId;

    final response = await _client.post('cart/update_qty', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> clearCart() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['m_sess_cart_id'] = _appLocal.sessionCartId;

    final response = await _client.post('cart/delete_cart', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> toggleFavourite({required String seoUrl}) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['seo_url'] = seoUrl;
    params['m_sess_cart_id'] = _appLocal.sessionCartId;

    final response =
        await _client.post('customer/update_to_favourite', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  List<MenuItemEntity> _parseFoodItems(List<dynamic> foodItems) {
    return foodItems.map((entry) {
      final map = entry as Map<String, dynamic>;
      final tempCart = map['temp_cart_obj'] as List<dynamic>? ?? [];
      String? tempCartItemId;
      var qty = 0;
      if (tempCart.isNotEmpty) {
        final first = tempCart.first as Map<String, dynamic>;
        tempCartItemId = first['id']?.toString();
        qty = int.tryParse(first['qty']?.toString() ?? '') ?? 0;
      }

      return MenuItemEntity(
        id: map['id']?.toString() ?? '',
        restaurantId: map['restaurants_id']?.toString() ?? '',
        name: map['display_item_name']?.toString() ?? '',
        description: map['description']?.toString(),
        image: map['image']?.toString(),
        foodType: map['food_type']?.toString(),
        actualPrice:
            double.tryParse(map['actual_price']?.toString() ?? '') ?? 0,
        applicablePrice:
            double.tryParse(map['applicable_price']?.toString() ?? '') ?? 0,
        available: (map['available']?.toString() ?? 'true') == 'true',
        isRecommended: (map['is_recommened']?.toString() ?? '0') == '1',
        isRestaurantOpen:
            (map['is_restaurant_opened']?.toString() ?? 'Open') != 'Closed',
        addOns: _parseAddons(map['add_ons'] as List<dynamic>? ?? []),
        options: _parseOptions(map['options'] as List<dynamic>? ?? []),
        tempCartItemId: tempCartItemId,
        quantity: qty,
      );
    }).toList();
  }

  List<MenuAddonEntity> _parseAddons(List<dynamic> addons) {
    return addons.map((entry) {
      final map = entry as Map<String, dynamic>;
      return MenuAddonEntity(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        price: double.tryParse(map['price']?.toString() ?? '') ?? 0,
        isMandatory: (map['is_mandatory']?.toString() ?? '0') == '1',
      );
    }).toList();
  }

  List<MenuOptionEntity> _parseOptions(List<dynamic> options) {
    return options.map((entry) {
      final map = entry as Map<String, dynamic>;
      return MenuOptionEntity(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        applicablePrice:
            double.tryParse(map['applicable_price']?.toString() ?? '') ?? 0,
        actualPrice:
            double.tryParse(map['actual_price']?.toString() ?? ''),
      );
    }).toList();
  }

  @override
  Future<RestaurantAboutEntity> getAbout({required String seoUrl}) async {
    final params = _paramsBuilder.baseParams();
    params['seo_url'] = seoUrl;

    final response = await _client.post('restaurant_data/about_us', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final hoursJson = data['business_hours'] as List<dynamic>? ?? [];
    final hours = hoursJson.map((entry) {
      final h = entry as Map<String, dynamic>;
      return RestaurantBusinessHourEntity(
        weekName: h['display_week_name']?.toString() ?? '',
        timings: h['display_timings']?.toString() ?? '',
      );
    }).toList();

    final latStr = data['latitude']?.toString();
    final lngStr = data['longitude']?.toString();

    return RestaurantAboutEntity(
      description: data['description']?.toString() ?? '',
      displayAddress: data['display_address']?.toString() ?? '',
      businessHours: hours,
      latitude: latStr != null && latStr != 'null'
          ? double.tryParse(latStr)
          : null,
      longitude: lngStr != null && lngStr != 'null'
          ? double.tryParse(lngStr)
          : null,
    );
  }

  @override
  Future<({List<RestaurantReviewEntity> items, int totalPages})> getReviews({
    required String seoUrl,
    required int page,
  }) async {
    final params = _paramsBuilder.baseParams();
    params['seo_url'] = seoUrl;
    params['page'] = page.toString();

    final response = await _client.post('restaurant_data/reviews', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return (items: <RestaurantReviewEntity>[], totalPages: 1);
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final totalPages =
        int.tryParse(data['total_pages']?.toString() ?? '1') ?? 1;
    final results = data['results'] as List<dynamic>? ?? [];

    final items = results.map((entry) {
      final map = entry as Map<String, dynamic>;
      return RestaurantReviewEntity(
        customerName: map['customer_name']?.toString() ?? '',
        feedback: map['restaurant_feed_back']?.toString() ?? '',
        rating:
            double.tryParse(map['restaurant_rating']?.toString() ?? '') ?? 0,
      );
    }).toList();

    return (items: items, totalPages: totalPages);
  }
}
