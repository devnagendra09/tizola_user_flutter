import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/cubit/main_cubit.dart';

/// Android `SuccessOrderFragment` — order placed, return to home.
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.refId});

  final String refId;

  void _goHome(BuildContext context) {
    final mainCubit = sl<MainCubit>();
    Navigator.of(context).popUntil((route) => route.isFirst);
    mainCubit.selectTab(0);
    mainCubit.refreshInProgressOrderAfterCheckout();
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
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Icon(
                  Icons.check_circle,
                  size: 88,
                  color: Colors.green.shade600,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Order placed successfully!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandLite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Order #$refId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You can track your order from the home screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goHome(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
