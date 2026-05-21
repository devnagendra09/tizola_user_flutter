import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/service_order_entity.dart';

abstract class OrdersRemoteDataSource {
  Future<ServiceOrderEntity> fetchServiceOrderView({required String refId});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._client, this._paramsBuilder);

  final ApiClient _client;
  final ApiParamsBuilder _paramsBuilder;

  @override
  Future<ServiceOrderEntity> fetchServiceOrderView({
    required String refId,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['ref_id'] = refId;
    params['request_from'] = 'mobile';

    final response = await _client.post('customer/service_order_view', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    return _parseServiceOrder(data);
  }

  ServiceOrderEntity _parseServiceOrder(Map<String, dynamic> data) {
    final restaurantRaw =
        data['restaurant_details'] as Map<String, dynamic>? ?? {};
    final restaurant = ServiceOrderRestaurant(
      name: restaurantRaw['restaurant_name']?.toString() ??
          data['restaurant_name']?.toString() ??
          '',
      displayAddress: restaurantRaw['display_address']?.toString() ??
          data['restaurant_display_address']?.toString(),
      mobile: restaurantRaw['mobile']?.toString(),
      imageUrl: restaurantRaw['display_image']?.toString(),
      latitude: restaurantRaw['latitude']?.toString() ??
          data['restaurant_lat']?.toString(),
      longitude: restaurantRaw['longitude']?.toString() ??
          data['restaurant_lng']?.toString(),
    );

    final cartItemsRaw = data['cart_items'] as List<dynamic>? ?? [];
    final cartItems = cartItemsRaw.map((entry) {
      final item = entry as Map<String, dynamic>;
      return ServiceOrderCartItem(
        name: item['item_name']?.toString() ??
            item['name']?.toString() ??
            '',
        quantity: item['qty']?.toString() ?? item['quantity']?.toString(),
        price: item['applicable_price']?.toString() ?? item['price']?.toString(),
      );
    }).toList();

    final logRaw = data['order_status_log'] as List<dynamic>? ?? [];
    final statusLog = logRaw.map((entry) {
      final log = entry as Map<String, dynamic>;
      return ServiceOrderStatusLog(
        label: log['display_lable']?.toString() ??
            log['display_label']?.toString() ??
            '',
        dateTime: log['date_time']?.toString(),
        isActive: log['action_activated']?.toString().toLowerCase() == 'yes',
        imageUrl: log['image']?.toString(),
      );
    }).toList();

    final remainRaw = data['remaing_time_obj'] as Map<String, dynamic>?;
    final remainSec = remainRaw?['total_remain_seconds'];
    int? remainingSeconds;
    if (remainSec is num) {
      remainingSeconds = remainSec.toInt();
    } else if (remainSec != null) {
      remainingSeconds = int.tryParse(remainSec.toString());
    }

    final landmark = data['landmark']?.toString() ?? '';
    final doorNo = data['door_no']?.toString() ?? '';
    final address = data['address']?.toString() ?? '';
    final deliveryAddress = [
      if (landmark.isNotEmpty) landmark,
      if (doorNo.isNotEmpty) doorNo,
      if (address.isNotEmpty) address,
    ].join(' ').trim();

    return ServiceOrderEntity(
      refId: data['ref_id']?.toString() ?? '',
      serviceStatus: data['service_status']?.toString() ?? '',
      grandTotal: data['grand_total']?.toString() ?? '0',
      restaurant: restaurant,
      statusLog: statusLog,
      cartItems: cartItems,
      deliveryOtp: data['delivery_otp']?.toString(),
      addressType: data['address_type']?.toString(),
      deliveryAddress: deliveryAddress.isEmpty ? null : deliveryAddress,
      customerCareNumber: data['customer_care_number']?.toString(),
      customerCareWhatsApp: data['customer_care_whats_app_number']?.toString(),
      selfPickAccepted:
          data['self_pick_accepted']?.toString().toLowerCase() == 'yes',
      remainingSeconds: remainingSeconds,
      subTotal: data['sub_total']?.toString(),
      deliveryCharges: data['applied_delivery_charge']?.toString() ??
          data['delivery_charges']?.toString(),
      discount: data['applied_discount_amount']?.toString() ??
          data['discount']?.toString(),
      taxes: data['applied_tax_amount']?.toString() ?? data['taxes']?.toString(),
      paidAmount: data['paid_amount']?.toString() ??
          data['through_wallet_amount']?.toString(),
      paymentStatus: data['payment_status']?.toString(),
      deliveryLatitude: double.tryParse(data['delivery_lat']?.toString() ?? ''),
      deliveryLongitude: double.tryParse(data['delivery_lng']?.toString() ?? ''),
    );
  }
}
