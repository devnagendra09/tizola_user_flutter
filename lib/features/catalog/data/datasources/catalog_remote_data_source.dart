import 'dart:convert';

import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/utils/json_parse_utils.dart';
import '../../domain/entities/cuisine_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/orders_page_entity.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/restaurant_page_entity.dart';
import '../../../main/domain/entities/in_progress_order_entity.dart';
import '../../../search/domain/entities/search_suggestion_entity.dart';
import '../../domain/enums/restaurant_food_filter.dart';
import '../../domain/enums/restaurant_price_option.dart';
import '../../domain/enums/restaurant_sort_option.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CuisineEntity>> getCuisines();
  Future<List<SearchSuggestionEntity>> searchRestaurantNames({
    required String keyword,
  });
  Future<RestaurantPageEntity> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
    List<String> cuisineIds = const [],
    RestaurantSortOption? sortOption,
    RestaurantPriceOption? priceOption,
    bool favouritesOnly = false,
    String? searchKey,
    bool refresh = false,
  });
  Future<OrdersPageEntity> getOrders({
    required String type,
    required int page,
  });

  Future<InProgressOrderEntity?> checkInProgressOrder();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(
    this._client,
    this._paramsBuilder,
    this._appLocal,
  );

  final ApiClient _client;
  final ApiParamsBuilder _paramsBuilder;
  final AppLocalDataSource _appLocal;

  @override
  Future<List<CuisineEntity>> getCuisines() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    final response = await _client.post('cuisines', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) => _parseCuisine(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SearchSuggestionEntity>> searchRestaurantNames({
    required String keyword,
  }) async {
    final params = _paramsBuilder.locationOnly();
    params['keyword'] = keyword.trim();

    final response = await _client.post('restaurant_names', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return [];
    }

    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return SearchSuggestionEntity(
        seoUrl: item['seo_url_for_mobile']?.toString(),
        restaurantName: item['restaurant_name']?.toString() ?? '',
        distance: item['distance']?.toString(),
        address: item['address']?.toString(),
        displayImage: item['display_image']?.toString(),
        type: item['type']?.toString(),
      );
    }).where((s) => s.restaurantName.isNotEmpty).toList();
  }

  @override
  Future<RestaurantPageEntity> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
    List<String> cuisineIds = const [],
    RestaurantSortOption? sortOption,
    RestaurantPriceOption? priceOption,
    bool favouritesOnly = false,
    String? searchKey,
    bool refresh = false,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['page'] = page.toString();
    params['m_sess_cart_id'] = _appLocal.sessionCartId;
    if (searchKey != null && searchKey.trim().isNotEmpty) {
      params['search_key'] = searchKey.trim();
    }
    if (favouritesOnly) {
      params['favourites'] = 'true';
    }
    params['food_type'] = switch (foodFilter) {
      RestaurantFoodFilter.veg => 'Veg',
      RestaurantFoodFilter.nonVeg => 'Non Veg',
      RestaurantFoodFilter.all => '',
    };
    final mobileFilters = <String, dynamic>{};
    if (cuisineIds.isNotEmpty) {
      mobileFilters['cuisines'] = cuisineIds;
    }
    if (sortOption != null) {
      mobileFilters['m_sort'] = sortOption.apiValue;
    }
    if (priceOption != null) {
      mobileFilters['m_price'] = priceOption.apiValue;
    }
    if (mobileFilters.isNotEmpty) {
      params['mobile_filters'] = jsonEncode(mobileFilters);
    }

    final response = await _client.post('restaurants/mobile', params);
    final json = ApiResponseParser.decodeMap(response.body);

    if (!ApiResponseParser.isValid(json)) {
      return RestaurantPageEntity(
        restaurants: const [],
        totalPages: 1,
        currentPage: page,
        emptyMessage: ApiResponseParser.message(json, 'No restaurants found'),
      );
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final results = data['results'] as List<dynamic>? ?? [];
    final restaurants = results
        .map((e) => _parseRestaurant(e as Map<String, dynamic>))
        .toList();

    return RestaurantPageEntity(
      restaurants: restaurants,
      totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
      currentPage: page,
      isStoreAvailable:
          JsonParseUtils.boolFlag(json['isStoreStatus'], defaultValue: true),
      cityImage: json['city_image']?.toString(),
    );
  }

  @override
  Future<OrdersPageEntity> getOrders({
    required String type,
    required int page,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    final token = params['access_token'];
    if (token == null || token.isEmpty) {
      throw const ServerFailure('Login required');
    }
    params['page'] = page.toString();
    params['type'] = type;
    params['is_mobile'] = '1';

    final response =
        await _client.post('customer/service_orders', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return OrdersPageEntity(
        orders: const [],
        totalPages: 1,
        emptyMessage: ApiResponseParser.message(json),
      );
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final results = data['results'] as List<dynamic>? ?? [];
    final orders = results
        .map((e) => _parseOrder(e as Map<String, dynamic>))
        .toList();
    return OrdersPageEntity(
      orders: orders,
      totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
      emptyMessage: json['message']?.toString(),
    );
  }

  @override
  Future<InProgressOrderEntity?> checkInProgressOrder() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    _paramsBuilder.addSessionCartId(params);
    final token = params['access_token'];
    if (token == null || token.isEmpty) return null;

    final response = await _client.post(
      'customer/check_for_any_in_progress_order',
      params,
    );
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return null;

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final orderData = data['order_data'] as Map<String, dynamic>? ?? data;
    final refId = orderData['ref_id']?.toString() ?? '';
    if (refId.isEmpty) return null;

    final otp = orderData['delivery_otp']?.toString();
    return InProgressOrderEntity(
      refId: refId,
      message: data['message']?.toString() ?? '',
      deliveryOtp: otp != null && otp.isNotEmpty ? otp : null,
      hasLiveTracking: _isTruthy(data['has_live_tracking_permission']),
      selfPickAccepted:
          orderData['self_pick_accepted']?.toString().toLowerCase() == 'yes',
    );
  }

  bool _isTruthy(dynamic value) {
    if (value is num) return value.toInt() == 1;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == '1' || v == 'true' || v == 'yes';
    }
    return false;
  }

  CuisineEntity _parseCuisine(Map<String, dynamic> json) {
    return CuisineEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      restaurantCount: json['number_of_restaurants']?.toString(),
      isOpened: json['is_opened']?.toString(),
    );
  }

  RestaurantEntity _parseRestaurant(Map<String, dynamic> json) {
    final foodTypeStr =
        json['food_type']?.toString().toLowerCase().trim() ?? '';
    final foodType = switch (foodTypeStr) {
      'veg' => FoodType.veg,
      'non veg' => FoodType.nonVeg,
      'both' => FoodType.both,
      _ => FoodType.both,
    };

    final prepTime = json['max_food_preparation_time']?.toString();
    final estimate = prepTime != null && prepTime != 'null'
        ? '$prepTime Min'
        : null;

    return RestaurantEntity(
      id: json['id']?.toString() ?? '',
      name: json['restaurant_name']?.toString() ?? '',
      seoUrl: json['seo_url']?.toString(),
      imageUrl: json['display_image']?.toString(),
      cuisineTypes: json['cuisine_types']?.toString(),
      estimateTime: estimate,
      offer: json['restaurant_offer']?.toString(),
      isOpened: json['is_opened']?.toString(),
      fromTime: json['from_time']?.toString(),
      toTime: json['to_time']?.toString(),
      distance: json['distance']?.toString(),
      address: json['display_address']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? ''),
      minimumOrderAmount: json['minimum_order_amount']?.toString(),
      foodType: foodType,
      isExclusive: JsonParseUtils.boolFlag(json['is_exclusive']),
      isFavourite: JsonParseUtils.boolFlag(json['is_favourite']),
    );
  }

  OrderEntity _parseOrder(Map<String, dynamic> json) {
    final feedbackFlag =
        int.tryParse(json['is_provided_feedback']?.toString() ?? '1') ?? 1;

    return OrderEntity(
      refId: json['ref_id']?.toString() ?? '',
      restaurantName: json['restaurant_name']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      grandTotal: json['grand_total']?.toString(),
      serviceStatus: json['service_status']?.toString(),
      cartItemsText: json['cart_items_txt']?.toString(),
      displayImage: json['display_image']?.toString(),
      deliveryPersonName: json['delivery_person_name']?.toString(),
      deliveryPersonContact:
          json['delivery_person_contact_number']?.toString(),
      deliveryBoyImage: json['delivery_boy_image']?.toString(),
      isFeedbackProvided: feedbackFlag != 0,
      selfPickAccepted:
          json['self_pick_accepted']?.toString().toLowerCase() == 'yes',
    );
  }
}
