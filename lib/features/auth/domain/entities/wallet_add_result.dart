import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_entity.dart';

/// Response from `customer/profile/add_wallet` before Razorpay checkout.
class WalletAddResult extends Equatable {
  const WalletAddResult({
    required this.refId,
    required this.razorpayOrderId,
    required this.amount,
    required this.checkoutInfo,
  });

  final String refId;
  final String razorpayOrderId;
  final String amount;
  final RazorpayCheckoutInfo checkoutInfo;

  @override
  List<Object?> get props => [refId, razorpayOrderId, amount, checkoutInfo];
}
