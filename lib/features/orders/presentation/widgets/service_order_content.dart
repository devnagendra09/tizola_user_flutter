import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/service_order_entity.dart';
import 'service_order_status_timeline.dart';

class ServiceOrderContent extends StatelessWidget {
  const ServiceOrderContent({
    super.key,
    required this.order,
    this.showLiveTrackButton = false,
    this.onLiveTrackTap,
  });

  final ServiceOrderEntity order;
  final bool showLiveTrackButton;
  final VoidCallback? onLiveTrackTap;

  Future<void> _call(String? number) async {
    if (number == null || number.isEmpty) return;
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (order.deliveryOtp != null && order.deliveryOtp!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandLite,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'OTP: ${order.deliveryOtp}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.brand,
              ),
            ),
          ),
        Text(
          'ORDER ID #${order.refId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          order.descriptionLine,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Restaurant'),
        Text(
          order.restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (order.restaurant.displayAddress != null)
          Text(order.restaurant.displayAddress!),
        const SizedBox(height: 12),
        if (!order.selfPickAccepted) ...[
          _sectionTitle('Delivery'),
          if (order.addressType != null)
            Text(
              order.addressType!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          if (order.deliveryAddress != null) Text(order.deliveryAddress!),
          const SizedBox(height: 12),
        ],
        _sectionTitle('Order status'),
        ServiceOrderStatusTimeline(items: order.statusLog),
        const SizedBox(height: 16),
        _sectionTitle('Items'),
        ...order.cartItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: Text(item.name)),
                if (item.quantity != null) Text('x${item.quantity}'),
                if (item.price != null) ...[
                  const SizedBox(width: 8),
                  Text('₹${item.price}'),
                ],
              ],
            ),
          ),
        ),
        const Divider(height: 24),
        if (order.subTotal != null) _billingRow('Sub total', order.subTotal!),
        if (order.deliveryCharges != null)
          _billingRow('Delivery', order.deliveryCharges!),
        if (order.discount != null) _billingRow('Discount', order.discount!),
        if (order.taxes != null) _billingRow('Taxes', order.taxes!),
        _billingRow('Grand total', order.grandTotal, bold: true),
        if (order.paidAmount != null)
          _billingRow('Paid', order.paidAmount!, bold: true),
        const SizedBox(height: 16),
        Row(
          children: [
            if (showLiveTrackButton && onLiveTrackTap != null)
              Expanded(
                child: ElevatedButton(
                  onPressed: onLiveTrackTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Live Tracking'),
                ),
              ),
            if (order.customerCareNumber != null &&
                order.customerCareNumber!.isNotEmpty) ...[
              if (showLiveTrackButton) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _call(order.customerCareNumber),
                  child: const Text('Help / Call'),
                ),
              ),
            ],
          ],
        ),
        if (order.selfPickAccepted) ...[
          const SizedBox(height: 16),
          _sectionTitle('Pickup location'),
          Row(
            children: [
              NetworkImageBox(
                url: order.restaurant.imageUrl,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurant.name),
                    if (order.restaurant.displayAddress != null)
                      Text(order.restaurant.displayAddress!),
                  ],
                ),
              ),
              if (order.restaurant.mobile != null)
                IconButton(
                  onPressed: () => _call(order.restaurant.mobile),
                  icon: const Icon(Icons.phone, color: AppColors.brand),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryBrand,
        ),
      ),
    );
  }

  Widget _billingRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹$value',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
