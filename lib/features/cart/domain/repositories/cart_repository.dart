import '../../../../core/utils/result.dart';
import '../entities/cart_entity.dart';

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

  Future<Result<void>> updateDeliveryLocation({required String addressId});

  Future<Result<void>> removeCouponCode();

  Future<Result<List<PaymentOptionEntity>>> fetchPaymentOptions({
    required String restaurantId,
  });

  Future<Result<CreateOrderResult>> createOrder({
    required String paymentMode,
    String? tipAmount,
    String? deliveryType,
  });

  Future<Result<void>> clearSessionCart();
}
