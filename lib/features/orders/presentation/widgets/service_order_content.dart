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
              color: AppColors.secondaryBrand,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    size: 10,
                    Icons.lock_outline,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4,),
                Text(
                  'OTP: ${order.deliveryOtp}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    'ORDER ID',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),

                  Text(
                    '#${order.refId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.serviceStatus,
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          order.descriptionLine,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),

        _sectionTitle('Restaurant'),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
          ),

          child: Row(
            children: [
              NetworkImageBox(
                url: order.restaurant.imageUrl,
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(14),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      order.restaurant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      order.restaurant.displayAddress ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => _call(order.restaurant.mobile),
                icon: const Icon(
                  Icons.phone,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!order.selfPickAccepted) ...[
          _sectionTitle('Delivery'),
          if (order.addressType != null)
            Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
          child:   Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  order.addressType!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              if (order.deliveryAddress != null) Text(order.deliveryAddress!),

            ],
          ),
            ),
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
        if (order.tipAmount != null &&
            order.tipAmount!.isNotEmpty &&
            order.tipAmount != '0')
          _billingRow('Delivery tips', order.tipAmount!),
        if (order.taxes != null) _billingRow('Applied taxes', order.taxes!),
        _billingRow('Grand total', order.grandTotal, bold: true),
        if (order.paidAmount != null)
          _billingRow('Paid', order.paidAmount!, bold: true),
        if (order.paymentStatus != null && order.paymentStatus!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Payment: ${order.paymentStatus}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
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
      padding: const EdgeInsets.only(
        bottom: 10,
        top: 6,
      ),
      child: Row(
        children: [

          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _billingRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),

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
      ),
    );
  }
}
