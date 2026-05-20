import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class PaymentOptionsPage extends StatefulWidget {
  const PaymentOptionsPage({
    super.key,
    required this.restaurantId,
    required this.payableAmount,
  });

  final String restaurantId;
  final String payableAmount;

  @override
  State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  List<PaymentOptionEntity> _options = [];
  bool _loading = true;
  bool _placingOrder = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await sl<CartRepository>().fetchPaymentOptions(
      restaurantId: widget.restaurantId,
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

  Future<void> _selectOption(PaymentOptionEntity option) async {
    if (option.isCod) {
      await _placeOrder(option);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Online payment (Razorpay) — coming soon'),
      ),
    );
  }

  Future<void> _placeOrder(PaymentOptionEntity option) async {
    setState(() => _placingOrder = true);

    final result = await sl<CartRepository>().createOrder(
      paymentMode: option.value,
    );

    if (!mounted) return;

    if (result.isFailure) {
      setState(() => _placingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure?.message ?? 'Order failed')),
      );
      return;
    }

    final order = result.data!;
    if (order.requiresOnlinePayment) {
      setState(() => _placingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Online payment — coming soon')),
      );
      return;
    }

    await sl<CartRepository>().clearSessionCart();
    if (!mounted) return;
    Navigator.of(context).pop(order.refId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Options'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const PaymentOptionsShimmer()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadOptions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        widget.payableAmount,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _options.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final option = _options[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                option.isCod
                                    ? Icons.payments_outlined
                                    : Icons.credit_card,
                                color: AppColors.brand,
                              ),
                              title: Text(option.label),
                              trailing: _placingOrder
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: _placingOrder
                                  ? null
                                  : () => _selectOption(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
