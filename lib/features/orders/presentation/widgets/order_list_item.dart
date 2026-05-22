import 'package:flutter/material.dart';

import '../../../../core/navigation/order_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../catalog/domain/entities/order_entity.dart';

/// Order row matching Android `item_order.xml` + `OrderAdapter`.
class OrderListItem extends StatelessWidget {
  const OrderListItem({super.key, required this.order});

  final OrderEntity order;

  Color _serviceStatusColor(BuildContext context) {
    final status = order.serviceStatus?.toLowerCase() ?? '';
    if (status == 'pending' || status == 'cancelled') {
      return Theme.of(context).colorScheme.error;
    }
    return AppColors.brand;
  }

  Color _paymentAmountColor() {
    final status = order.paymentStatus?.toLowerCase() ?? '';
    if (status == 'pending') return const Color(0xFFE40000);
    return const Color(0xFF008000);
  }

  @override
  Widget build(BuildContext context) {
    final paymentStatus = order.paymentStatus ?? '';
    final grandTotal = order.grandTotal ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.restaurantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order.deliveryAddress != null &&
                order.deliveryAddress!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                order.deliveryAddress!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (order.cartItemsText != null &&
                order.cartItemsText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandLite.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.cartItemsText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            _LabelValueRow(
              label: 'Payment status',
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 13,
                      ),
                  children: [
                    TextSpan(text: '$paymentStatus : '),
                    TextSpan(
                      text: '₹$grandTotal',
                      style: TextStyle(
                        color: _paymentAmountColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            _LabelValueRow(
              label: 'Service status',
              child: Text(
                order.serviceStatus ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: _serviceStatusColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => openOrderDetail(
                    context,
                    refId: order.refId,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brand,
                    side: const BorderSide(color: AppColors.brand),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('View order summary'),
                ),
                const Spacer(),
                if (order.canLeaveFeedback)
                  OutlinedButton(
                    onPressed: () => openOrderReview(context, order: order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Leave feedback'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
