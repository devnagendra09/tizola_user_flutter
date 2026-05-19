import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/cart_entity.dart';

abstract class CartRemoteDataSource {
  Future<CartEntity> fetchCart({
    String? couponCode,
    String? addressId,
    String? tipAmount,
    String? deliveryType,
  });

  Future<void> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<void> removeItem({required String cartItemId});

  Future<void> updateDeliveryLocation({required String addressId});

  Future<void> removeCouponCode();

  Future<List<PaymentOptionEntity>> fetchPaymentOptions({
    required String restaurantId,
  });

  Future<CreateOrderResult> createOrder({
    required String paymentMode,
    String? tipAmount,
    String? deliveryType,
  });

  Future<void> clearSessionCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl(
    this._client,
    this._paramsBuilder,
    this._appLocal,
  );

  final ApiClient _client;
  final ApiParamsBuilder _paramsBuilder;
  final AppLocalDataSource _appLocal;

  Map<String, String> _cartBaseParams() {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['m_sess_cart_id'] = _appLocal.deviceId;
    params['creation_source'] = AppConstants.source;
    return params;
  }

  @override
  Future<CartEntity> fetchCart({
    String? couponCode,
    String? addressId,
    String? tipAmount,
    String? deliveryType,
  }) async {
    final params = _cartBaseParams();
    if (couponCode != null && couponCode.isNotEmpty) {
      params['coupon_code'] = couponCode;
    }
    if (addressId != null && addressId.isNotEmpty) {
      params['customers_addresses_id'] = addressId;
    }
    if (tipAmount != null && tipAmount.isNotEmpty) {
      params['tip_amount'] = tipAmount;
    }
    if (deliveryType != null && deliveryType.isNotEmpty) {
      params['delivery_type'] = deliveryType;
    }

    final response = await _client.post('cart', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return const CartEntity();
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final restaurantInfo =
        data['restaurant_info'] as Map<String, dynamic>? ?? {};
    final cartItems = data['cart_items'] as List<dynamic>? ?? [];
    final taxesJson = data['taxes'] as List<dynamic>? ?? [];

    return CartEntity(
      restaurant: CartRestaurantInfoEntity(
        name: restaurantInfo['name']?.toString() ?? '',
        image: restaurantInfo['display_image']?.toString(),
        address: restaurantInfo['display_address']?.toString(),
        cuisineTypes: restaurantInfo['cuisine_types']?.toString(),
        minimumOrderAmount:
            restaurantInfo['minimum_order_amount']?.toString(),
      ),
      items: cartItems.map((entry) {
        final map = entry as Map<String, dynamic>;
        return CartItemEntity(
          id: map['id']?.toString() ?? '',
          name: map['item_name']?.toString() ?? '',
          quantity: int.tryParse(map['qty']?.toString() ?? '') ?? 0,
          applicablePrice:
              double.tryParse(map['applicable_price']?.toString() ?? '') ?? 0,
          image: map['image']?.toString(),
          optionsName: map['restaurant_food_options_name']?.toString(),
          addonsNames: map['restaurant_food_item_addons_names']?.toString(),
        );
      }).toList(),
      taxes: taxesJson.map((entry) {
        final map = entry as Map<String, dynamic>;
        return CartTaxEntity(
          name: map['tax_name']?.toString() ?? '',
          amount: map['applied_tax_amount']?.toString() ?? '',
        );
      }).toList(),
      subTotal: data['sub_total']?.toString(),
      couponCode: data['coupon_code']?.toString(),
      appliedDiscountAmount: data['applied_discount_amount']?.toString(),
      appliedTaxAmount: data['applied_tax_amount']?.toString(),
      appliedDeliveryCharge: data['applied_delivery_charge']?.toString(),
      promotionWalletAmount: data['promotion_wallet_amount']?.toString(),
      grandTotal: data['grand_total']?.toString(),
      couponDiscountMessage: data['coupon_discount_message']?.toString(),
      hasCouponDiscount: data['has_coupon_discount'] == true,
      restaurantId: data['restaurants_id']?.toString(),
      deliveryAddress: (data['delivery_address'] as Map<String, dynamic>?)?['address']
          ?.toString(),
    );
  }

  @override
  Future<void> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final params = _cartBaseParams();
    params['id'] = cartItemId;
    params['qty'] = quantity.toString();

    final response = await _client.post('cart/update_qty', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> removeItem({required String cartItemId}) async {
    final params = _cartBaseParams();
    params['id'] = cartItemId;

    final response = await _client.post('cart/update_qty', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> updateDeliveryLocation({required String addressId}) async {
    final params = _cartBaseParams();
    params['customers_addresses_id'] = addressId;

    final response = await _client.post('cart/update_delivery_location', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> removeCouponCode() async {
    final params = _cartBaseParams();
    final response = await _client.post('cart/remove_coupon_code', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<List<PaymentOptionEntity>> fetchPaymentOptions({
    required String restaurantId,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['restaurant_id'] = restaurantId;

    final response =
        await _client.post('customer/payment_options_config', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((entry) {
          final map = entry as Map<String, dynamic>;
          return PaymentOptionEntity(
            label: map['label']?.toString() ?? map['name']?.toString() ?? '',
            value: map['value']?.toString() ?? '',
          );
        })
        .where((option) => option.value.isNotEmpty)
        .toList();
  }

  @override
  Future<CreateOrderResult> createOrder({
    required String paymentMode,
    String? tipAmount,
    String? deliveryType,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['m_sess_cart_id'] = _appLocal.deviceId;
    params['payment_mode'] = paymentMode;
    if (tipAmount != null && tipAmount.isNotEmpty) {
      params['tip_amount'] = tipAmount;
    }
    if (deliveryType != null && deliveryType.isNotEmpty) {
      params['delivery_type'] = deliveryType;
    }

    final response = await _client.post('create_order', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final isCod = paymentMode.toLowerCase().contains('delivery');
    final hasRazorpay = json.containsKey('razor_pay_info');
    return CreateOrderResult(
      refId: json['ref_id']?.toString() ?? '',
      requiresOnlinePayment: !isCod && hasRazorpay,
    );
  }

  @override
  Future<void> clearSessionCart() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['m_sess_cart_id'] = _appLocal.deviceId;

    final response = await _client.post('customer/clear_cart', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }
}
