import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../injection_container.dart';
import '../../data/services/razorpay_checkout_service.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'payment_web_page.dart';
import '../widgets/payment_gateway_tile.dart';

/// Android `PaymentOptionsFragment` + `CartActivity` — native Razorpay SDK only.
class PaymentOptionsPage extends StatefulWidget {
  const PaymentOptionsPage({
    super.key,
    required this.restaurantId,
    required this.payableAmount,
    this.orderType,
    this.tipAmount,
    this.deliveryType,
    this.isWalletChecked = 'no',
    this.usedWalletAmount = '0',
  });

  final String restaurantId;
  final String payableAmount;
  final String? orderType;
  final String? tipAmount;
  final String? deliveryType;
  final String isWalletChecked;
  final String usedWalletAmount;

  @override
  State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  final CartRepository _cartRepository = sl<CartRepository>();
  final RazorpayCheckoutService _razorpayCheckout = RazorpayCheckoutService();

  List<PaymentOptionEntity> _options = [];
  int? _selectedIndex;
  bool _loading = true;
  bool _placingOrder = false;
  String? _error;
  String? _pendingRefId;

  @override
  void initState() {
    super.initState();
    _razorpayCheckout.attach(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
      onExternalWallet: _onExternalWallet,
    );
    _loadOptions();
  }

  @override
  void dispose() {
    _razorpayCheckout.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedIndex = null;
    });

    final result = await _cartRepository.fetchPaymentOptions(
      restaurantId: widget.restaurantId,
      orderType: widget.orderType,
    );

    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failure?.message ?? 'Failed to load payment options';
      });
      return;
    }

    setState(() {
      _loading = false;
      _options = result.data ?? [];
    });
  }

  void _onGatewayTap(int index) {
    final option = _options[index];
    if (!option.enabled) {
      _showMessage(
        'Currently we are not accepting ${option.label}. Please try another method',
      );
      return;
    }
    setState(() => _selectedIndex = index);
    _placeOrder(option);
  }

  /// Android: both COD and online call `creatingOrder()`; branch on payment mode after response.
  Future<void> _placeOrder(PaymentOptionEntity option) async {
    setState(() => _placingOrder = true);

    final result = await _cartRepository.createOrder(
      paymentMode: option.value,
      tipAmount: widget.tipAmount,
      deliveryType: widget.deliveryType,
      isWalletChecked: widget.isWalletChecked,
      usedWalletAmount: widget.usedWalletAmount,
    );

    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _placingOrder = false;
        _selectedIndex = null;
      });
      _showMessage(result.failure?.message ?? 'Order failed');
      return;
    }

    final order = result.data!;
    if (order.refId.isEmpty) {
      setState(() {
        _placingOrder = false;
        _selectedIndex = null;
      });
      _showMessage('Invalid order response');
      return;
    }

    _pendingRefId = order.refId;

    if (option.isCod) {
      await _finishCodOrder(order.refId);
      return;
    }

    await _startOnlinePayment(order);
  }

  Future<void> _finishCodOrder(String refId) async {
    final clearResult = await _cartRepository.clearSessionCart();
    if (!mounted) return;

    setState(() {
      _placingOrder = false;
      _selectedIndex = null;
    });

    if (clearResult.isFailure) {
      _showMessage(clearResult.failure?.message ?? 'Failed to clear cart');
      return;
    }

    Navigator.of(context).pop(refId);
  }

  Future<void> _startOnlinePayment(CreateOrderResult order) async {
    setState(() => _placingOrder = false);

    if (order.hasRazorpay) {
      try {
        _razorpayCheckout.open(order.razorpayInfo!);
      } catch (e) {
        setState(() => _selectedIndex = null);
        await _cancelPendingOrder();
        _showMessage('Could not open payment gateway');
      }
      return;
    }

    if (order.hasWebPayment) {
      await _startWebPayment(order.refId, order.paymentGatewayWebUrl!);
      return;
    }

    setState(() => _selectedIndex = null);
    await _cancelPendingOrder();
    _showMessage('Online payment is not available. Please try another method.');
  }

  /// `payment_gateway_web_url` from create_order (Android `PaymentWebFragment`).
  Future<void> _startWebPayment(String refId, String paymentUrl) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentWebPage(
          paymentUrl: paymentUrl,
          refId: refId,
        ),
      ),
    );

    if (!mounted) return;

    if (paid == true) {
      await _finishCodOrder(refId);
      return;
    }

    setState(() => _selectedIndex = null);
    await _cancelPendingOrder();
  }

  Future<void> _finishOnlineOrder(String refId, String paymentId) async {
    setState(() => _placingOrder = true);

    final markResult = await _cartRepository.markRazorpayPaymentSuccessful(
      refId: refId,
      paymentId: paymentId,
    );

    if (!mounted) return;

    if (markResult.isFailure) {
      setState(() {
        _placingOrder = false;
        _selectedIndex = null;
      });
      _showMessage(
        markResult.failure?.message ?? 'Payment verification failed',
      );
      return;
    }

    final clearResult = await _cartRepository.clearSessionCart();
    if (!mounted) return;

    setState(() {
      _placingOrder = false;
      _selectedIndex = null;
    });

    if (clearResult.isFailure) {
      _showMessage(clearResult.failure?.message ?? 'Failed to clear cart');
      return;
    }

    Navigator.of(context).pop(refId);
  }

  Future<void> _cancelPendingOrder() async {
    final refId = _pendingRefId;
    if (refId == null || refId.isEmpty) return;
    await _cartRepository.cancelOrderOnPaymentCancelled(refId: refId);
    _pendingRefId = null;
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    final paymentId = response.paymentId;
    final refId = _pendingRefId;
    if (paymentId == null || paymentId.isEmpty || refId == null) {
      _showMessage('Payment succeeded but order reference is missing');
      return;
    }
    _finishOnlineOrder(refId, paymentId);
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _cancelPendingOrder();
    if (!mounted) return;
    setState(() {
      _placingOrder = false;
      _selectedIndex = null;
    });
    final code = response.code;
    final message = response.message;
    _showMessage(
      code == Razorpay.PAYMENT_CANCELLED
          ? 'Payment cancelled'
          : (message ?? 'Payment failed'),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _showMessage('External wallet: ${response.walletName ?? ''}');
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<bool> _confirmLeaveWhilePending() async {
    if (_placingOrder) return false;
    if (_pendingRefId == null) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment status..!'),
        content: const Text(
          'Right now your payment is in the process. '
          'Are you sure you want to cancel the payment forcefully?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmLeaveWhilePending();
        if (leave && context.mounted) {
          if (_pendingRefId != null) {
            await _cancelPendingOrder();
          }
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.splash,
        appBar: AppBar(
          title: const Text('Payment Options'),
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            _buildContent(),
            if (_placingOrder) _buildLoaderOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaderOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.brand),
                SizedBox(height: 16),
                Text('Processing order...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const PaymentOptionsShimmer();

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: _loadOptions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_options.isEmpty) {
      return const Center(child: Text('No payment methods available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'TIZOLA',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.secondaryBrand,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.isWalletChecked == 'yes' && (double.tryParse(widget.usedWalletAmount) ?? 0) > 0)
                    const Text(
                      'Wallet applied',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    widget.payableAmount.contains('0.00') ? 'FREE' : widget.payableAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'SELECT ANY OPTION TO PAY',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _options.length,
            itemBuilder: (_, index) {
              final option = _options[index];
              return PaymentGatewayTile(
                option: option,
                selected: _selectedIndex == index,
                onTap: _placingOrder ? () {} : () => _onGatewayTap(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
