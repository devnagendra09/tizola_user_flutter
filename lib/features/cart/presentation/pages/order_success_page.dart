import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/pages/order_detail_page.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/cubit/main_cubit.dart';

/// Android `SuccessOrderFragment` → `OrdersActivity` with `ref_id`.
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.refId});

  final String refId;

  void _goHome(BuildContext context) {
    final mainCubit = sl<MainCubit>();
    Navigator.of(context).popUntil((route) => route.isFirst);
    mainCubit.selectTab(0);
    mainCubit.refreshInProgressOrderAfterCheckout();
  }

  void _viewOrderInfo(BuildContext context) {
    sl<MainCubit>().refreshInProgressOrderAfterCheckout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(refId: refId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Placed'),
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goHome(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.storefront_outlined,
                  size: 120,
                  color: AppColors.brand.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Order has been Placed Successfully',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank You for Your Order. You will be notified once order is accepted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ORDER ID :',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  refId,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _viewOrderInfo(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('View order Info'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _goHome(context),
                  child: const Text('Continue shopping'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
