import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/in_progress_order_entity.dart';

/// Android `viewTrack` — order status strip above bottom navigation.
class OrderStatusTrackBar extends StatelessWidget {
  const OrderStatusTrackBar({
    super.key,
    required this.order,
    required this.onTrackTap,
  });

  final InProgressOrderEntity order;
  final VoidCallback onTrackTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Order #${order.refId}\n',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: order.message),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
              if (order.deliveryOtp != null) ...[
                const SizedBox(width: 6),
                Text(
                  'OTP: ${order.deliveryOtp}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              TextButton(
                onPressed: onTrackTap,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 25),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: AppColors.splash,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                child: Text(
                  order.trackButtonLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
