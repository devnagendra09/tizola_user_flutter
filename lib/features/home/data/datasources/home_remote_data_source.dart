import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/home_banner_entity.dart';

abstract class HomeRemoteDataSource {
  Future<String?> getNotificationMessage();
  Future<List<HomeBannerEntity>> getCouponBanners();
  Future<List<HomeSliderEntity>> getSliders();
  Future<CustomerCareEntity> getCustomerCare();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._client, this._paramsBuilder);

  final ApiClient _client;
  final ApiParamsBuilder _paramsBuilder;

  @override
  Future<String?> getNotificationMessage() async {
    final params = _paramsBuilder.baseParams();
    final response =
        await _client.post('customer/weather_or_other_notification', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return null;
    final data = json['data'] as Map<String, dynamic>?;
    return data?['message']?.toString();
  }

  @override
  Future<List<HomeBannerEntity>> getCouponBanners() async {
    final params = _paramsBuilder.baseParams();
    params.addAll(_paramsBuilder.locationOnly());
    final response = await _client.post('available_coupons', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return [];

    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      final restaurant =
          map['restaurant_details'] as Map<String, dynamic>?;
      return HomeBannerEntity(
        id: map['id']?.toString() ?? '',
        promotionImage: map['promotion_image_in_mobile']?.toString(),
        restaurantId: restaurant?['id']?.toString(),
        restaurantName: restaurant?['restaurant_name']?.toString(),
        restaurantSeoUrl: restaurant?['seo_url']?.toString(),
      );
    }).toList();
  }

  @override
  Future<List<HomeSliderEntity>> getSliders() async {
    final params = _paramsBuilder.baseParams();
    params.addAll(_paramsBuilder.locationOnly());
    final response =
        await _client.post('customer/home_page_sliders', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return [];

    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return HomeSliderEntity(
        id: map['id']?.toString() ?? '',
        image: map['image']?.toString(),
        redirectionUrl: map['redirection_url']?.toString(),
      );
    }).toList();
  }

  @override
  Future<CustomerCareEntity> getCustomerCare() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    final response = await _client.post('customer_care_number', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CustomerCareEntity(
      phone: data['customer_care_number']?.toString(),
      whatsapp: data['customer_care_whats_app_number']?.toString(),
    );
  }
}
