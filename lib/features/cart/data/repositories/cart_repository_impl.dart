import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/coupon_offer_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._remote);

  final CartRemoteDataSource _remote;

  @override
  Future<Result<CartEntity>> fetchCart({
    String? couponCode,
    String? addressId,
    String? tipAmount,
    String? deliveryType,
  }) async {
    try {
      final data = await _remote.fetchCart(
        couponCode: couponCode,
        addressId: addressId,
        tipAmount: tipAmount,
        deliveryType: deliveryType,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      await _remote.updateItemQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> removeItem({required String cartItemId}) async {
    try {
      await _remote.removeItem(cartItemId: cartItemId);
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> updateDeliveryLocation({
    required String addressId,
  }) async {
    try {
      await _remote.updateDeliveryLocation(addressId: addressId);
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> removeCouponCode() async {
    try {
      await _remote.removeCouponCode();
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<CouponOfferEntity>>> fetchAvailableCoupons() async {
    try {
      final data = await _remote.fetchAvailableCoupons();
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<String>>> fetchTipAmounts() async {
    try {
      final data = await _remote.fetchTipAmounts();
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<PaymentOptionEntity>>> fetchPaymentOptions({
    required String restaurantId,
    String? orderType,
  }) async {
    try {
      final data = await _remote.fetchPaymentOptions(
        restaurantId: restaurantId,
        orderType: orderType,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<CreateOrderResult>> createOrder({
    required String paymentMode,
    String? tipAmount,
    String? deliveryType,
  }) async {
    try {
      final data = await _remote.createOrder(
        paymentMode: paymentMode,
        tipAmount: tipAmount,
        deliveryType: deliveryType,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> markRazorpayPaymentSuccessful({
    required String refId,
    required String paymentId,
  }) async {
    try {
      await _remote.markRazorpayPaymentSuccessful(
        refId: refId,
        paymentId: paymentId,
      );
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> cancelOrderOnPaymentCancelled({
    required String refId,
  }) async {
    try {
      await _remote.cancelOrderOnPaymentCancelled(refId: refId);
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> clearSessionCart() async {
    try {
      await _remote.clearSessionCart();
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
