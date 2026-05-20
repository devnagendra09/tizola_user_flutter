import 'dart:convert';

import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/utils/json_parse_utils.dart';
import '../../domain/entities/cuisine_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../../home/domain/entities/restaurant_page_entity.dart';
import '../../domain/enums/restaurant_food_filter.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CuisineEntity>> getCuisines();
  Future<RestaurantPageEntity> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
    List<String> cuisineIds = const [],
    bool refresh = false,
  });
  Future<({List<OrderEntity> orders, int totalPages})> getOrders({
    required String type,
    required int page,
  });
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
  Future<RestaurantPageEntity> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
    List<String> cuisineIds = const [],
    bool refresh = false,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['page'] = page.toString();
    params['m_sess_cart_id'] = _appLocal.deviceId;
    params['food_type'] = switch (foodFilter) {
      RestaurantFoodFilter.veg => 'Veg',
      RestaurantFoodFilter.nonVeg => 'Non Veg',
      RestaurantFoodFilter.all => '',
    };
    if (cuisineIds.isNotEmpty) {
      params['mobile_filters'] = jsonEncode({'cuisines': cuisineIds});
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
  Future<({List<OrderEntity> orders, int totalPages})> getOrders({
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
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final results = data['results'] as List<dynamic>? ?? [];
    final orders = results
        .map((e) => _parseOrder(e as Map<String, dynamic>))
        .toList();
    return (
      orders: orders,
      totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
    );
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
    );
  }
}
