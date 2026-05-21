import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/entities/cart_entity.dart';

typedef RazorpayPaymentSuccess = void Function(PaymentSuccessResponse response);
typedef RazorpayPaymentFailure = void Function(PaymentFailureResponse response);
typedef RazorpayExternalWallet = void Function(ExternalWalletResponse response);

/// Native Razorpay Checkout SDK wrapper (`com.razorpay:checkout` on Android,
/// `razorpay-pod` on iOS) via [razorpay_flutter]. Does not use WebView.
class RazorpayCheckoutService {
  Razorpay? _razorpay;

  void attach({
    required RazorpayPaymentSuccess onSuccess,
    required RazorpayPaymentFailure onError,
    RazorpayExternalWallet? onExternalWallet,
  }) {
    _razorpay?.clear();
    _razorpay = Razorpay();
    _razorpay!
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    if (onExternalWallet != null) {
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
  }

  /// Opens native CheckoutActivity (Android) / Razorpay UI (iOS).
  void open(RazorpayCheckoutInfo info) {
    final razorpay = _razorpay;
    if (razorpay == null) {
      throw StateError('RazorpayCheckoutService.attach() must be called first');
    }
    razorpay.open(info.toCheckoutOptions());
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
