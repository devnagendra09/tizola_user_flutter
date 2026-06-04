import '../../../../core/utils/result.dart';
import '../entities/cart_entity.dart';
import '../entities/coupon_offer_entity.dart';
import '../entities/delivery_location_update_result.dart';

abstract class CartRepository {
  Future<Result<CartEntity>> fetchCart({
    String? couponCode,
    String? addressId,
    String? tipAmount,
    String? deliveryType,
  });

  Future<Result<void>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<Result<void>> removeItem({required String cartItemId});

  Future<Result<DeliveryLocationUpdateResult>> updateDeliveryLocation({
    required String addressId,
  });

  Future<Result<void>> removeCouponCode();

  Future<Result<List<CouponOfferEntity>>> fetchAvailableCoupons();

  Future<Result<List<String>>> fetchTipAmounts();

  Future<Result<List<PaymentOptionEntity>>> fetchPaymentOptions({
    required String restaurantId,
    String? orderType,
  });

  Future<Result<CreateOrderResult>> createOrder({
    required String paymentMode,
    String? tipAmount,
    String? deliveryType,
  });

  Future<Result<void>> markRazorpayPaymentSuccessful({
    required String refId,
    required String paymentId,
  });

  Future<Result<void>> cancelOrderOnPaymentCancelled({required String refId});

  Future<Result<void>> clearSessionCart();

  Future<Result<int>> fetchCartItemCount();
}
