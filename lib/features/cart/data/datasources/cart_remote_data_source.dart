import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/coupon_offer_entity.dart';

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

  Future<List<CouponOfferEntity>> fetchAvailableCoupons();

  Future<List<String>> fetchTipAmounts();

  Future<List<PaymentOptionEntity>> fetchPaymentOptions({
    required String restaurantId,
    String? orderType,
  });

  Future<CreateOrderResult> createOrder({
    required String paymentMode,
    String? tipAmount,
    String? deliveryType,
  });

  Future<void> markRazorpayPaymentSuccessful({
    required String refId,
    required String paymentId,
  });

  Future<void> cancelOrderOnPaymentCancelled({required String refId});

  Future<void> clearSessionCart();

  /// Total qty across `cart_items` — Android `MainActivity.fetchCart` badge.
  Future<int> fetchCartItemCount();
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
    _paramsBuilder.addSessionCartId(params);
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
    // Android sends tip_amount="" or "0" when clearing tip on cart refresh.
    if (tipAmount != null) {
      params['tip_amount'] = tipAmount.isEmpty ? '0' : tipAmount;
    }
    if (deliveryType != null && deliveryType.isNotEmpty) {
      params['delivery_type'] = deliveryType;
    }

    final response = await _client.post('cart', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      // Android hides main cart UI when err_code is not valid (empty cart).
      return const CartEntity();
    }

    final data = json['data'] as Map<String, dynamic>? ?? {};
    final cartItems = data['cart_items'] as List<dynamic>? ?? [];
    if (cartItems.isEmpty) {
      return const CartEntity();
    }

    final restaurantInfo =
        data['restaurant_info'] as Map<String, dynamic>? ?? {};
    final taxesJson = data['taxes'] as List<dynamic>? ?? [];

    return CartEntity(
      restaurant: CartRestaurantInfoEntity(
        name: restaurantInfo['name']?.toString() ?? '',
        image: restaurantInfo['display_image']?.toString(),
        address: restaurantInfo['display_address']?.toString(),
        cuisineTypes: restaurantInfo['cuisine_types']?.toString(),
        minimumOrderAmount:
            restaurantInfo['minimum_order_amount']?.toString(),
        providingSelfPickup:
            restaurantInfo['providing_self_pickup']?.toString().toLowerCase() ==
                'yes',
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
      appliedTipAmount: data['tip_amount']?.toString(),
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
  Future<List<CouponOfferEntity>> fetchAvailableCoupons() async {
    final params = _cartBaseParams();
    params.addAll(_paramsBuilder.locationOnly());

    final response = await _client.post('available_coupons', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((entry) {
      final map = entry as Map<String, dynamic>;
      return CouponOfferEntity(
        couponCode: map['coupon_code']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString(),
        displayEndDate: map['display_end_date']?.toString(),
      );
    }).where((c) => c.couponCode.isNotEmpty).toList();
  }

  @override
  Future<List<String>> fetchTipAmounts() async {
    final response = await _client.get('tips_amount_list');
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return [];

    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => (e as Map<String, dynamic>)['tip_amount']?.toString() ?? '')
        .where((amount) => amount.isNotEmpty)
        .toList();
  }

  @override
  Future<List<PaymentOptionEntity>> fetchPaymentOptions({
    required String restaurantId,
    String? orderType,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['restaurant_id'] = restaurantId;
    if (orderType != null && orderType.isNotEmpty) {
      params['order_type'] = orderType;
    }

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
          final enabledRaw = map['enabled'];
          final enabled = enabledRaw == null ||
              enabledRaw == true ||
              enabledRaw.toString() == '1' ||
              enabledRaw.toString().toLowerCase() == 'true';
          return PaymentOptionEntity(
            label: map['name']?.toString() ?? map['label']?.toString() ?? '',
            value: map['value']?.toString() ?? '',
            imageUrl: map['image']?.toString(),
            enabled: enabled,
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
    _paramsBuilder.addSessionCartId(params);
    params['payment_mode'] = paymentMode;

    final isSelfPick = deliveryType == 'selfpick';
    if (deliveryType != null && deliveryType.isNotEmpty) {
      params['delivery_type'] = deliveryType;
    }
    // Android PaymentOptionsFragment: tip_amount="" when not selfpick.
    if (!isSelfPick) {
      params['tip_amount'] = tipAmount ?? '';
    }

    final response = await _client.post('create_order', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }

    final webUrl = json['payment_gateway_web_url']?.toString();

    return CreateOrderResult(
      refId: json['ref_id']?.toString() ?? '',
      razorpayInfo: _parseRazorpayInfo(json),
      paymentGatewayWebUrl:
          webUrl != null && webUrl.isNotEmpty ? webUrl : null,
    );
  }

  RazorpayCheckoutInfo? _parseRazorpayInfo(Map<String, dynamic> json) {
    dynamic raw = json['razor_pay_info'];
    if (raw == null && json['data'] is Map<String, dynamic>) {
      raw = (json['data'] as Map<String, dynamic>)['razor_pay_info'];
    }
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
    final key = map['key']?.toString() ?? '';
    final meta = map['meta_info'];
    if (key.isEmpty || meta is! Map) return null;

    return RazorpayCheckoutInfo(
      key: key,
      metaInfo: Map<String, dynamic>.from(
        meta.map((k, v) => MapEntry(k.toString(), v)),
      ),
    );
  }

  @override
  Future<void> markRazorpayPaymentSuccessful({
    required String refId,
    required String paymentId,
  }) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['ref_id'] = refId;
    params['payment_id'] = paymentId;
    params['sess_cart_id'] = _appLocal.sessionCartId;

    final response = await _client.post(
      'customer/mark_as_payment_successful/with_razor_pay',
      params,
    );
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> cancelOrderOnPaymentCancelled({required String refId}) async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    params['ref_id'] = refId;

    final response = await _client.post(
      'customer/cancel_order_when_payment_cancelled',
      params,
    );
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<void> clearSessionCart() async {
    final params = _paramsBuilder.baseParams(includeSource: false);
    _paramsBuilder.addSessionCartId(params);

    final response = await _client.post('customer/clear_cart', params);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw ServerFailure(ApiResponseParser.message(json));
    }
  }

  @override
  Future<int> fetchCartItemCount() async {
    final response = await _client.post('cart', _cartBaseParams());
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) return 0;

    final cartItems =
        (json['data'] as Map<String, dynamic>?)?['cart_items'] as List<dynamic>? ??
            [];
    var qty = 0;
    for (final item in cartItems) {
      qty += int.tryParse(
            (item as Map<String, dynamic>)['qty']?.toString() ?? '',
          ) ??
          0;
    }
    return qty;
  }
}
