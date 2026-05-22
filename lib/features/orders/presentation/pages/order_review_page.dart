import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_params_builder.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/entities/order_entity.dart';

/// Android `ReviewActivity` + `customer/update_order_feedback`.
class OrderReviewPage extends StatefulWidget {
  const OrderReviewPage({super.key, required this.order});

  final OrderEntity order;

  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  final _restaurantComment = TextEditingController();
  final _driverComment = TextEditingController();
  double _restaurantRating = 0;
  int _driverRating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _restaurantComment.dispose();
    _driverComment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_restaurantRating <= 0) {
      _showSnack('Please rate the order.');
      return;
    }
    if (!widget.order.selfPickAccepted && _driverRating <= 0) {
      _showSnack('Please rate driver services.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final params = sl<ApiParamsBuilder>().baseParams(includeSource: false);
      params['ref_id'] = widget.order.refId;
      params['restaurant_feed_back'] = _restaurantComment.text.trim();
      params['restaurant_rating'] = _restaurantRating.toString();
      params['delivery_person_feedback'] = _driverComment.text.trim();
      params['delivery_person_rating'] = _driverRating.toString();

      final response = await sl<ApiClient>().post(
        'customer/update_order_feedback',
        params,
      );
      final json = ApiResponseParser.decodeMap(response.body);
      if (!mounted) return;

      if (ApiResponseParser.isValid(json)) {
        Navigator.of(context).pop(true);
      } else {
        _showSnack(ApiResponseParser.message(json));
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to submit feedback');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final showDriver = !order.selfPickAccepted;
    final driverName = order.deliveryPersonName ?? 'Delivery partner';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate your order'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageBox(
                  url: order.displayImage,
                  width: 56,
                  height: 56,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Restaurant rating',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                onPressed: () => setState(() => _restaurantRating = star.toDouble()),
                icon: Icon(
                  star <= _restaurantRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          TextField(
            controller: _restaurantComment,
            decoration: const InputDecoration(
              labelText: 'Comments about restaurant',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          if (showDriver) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: NetworkImageBox(
                    url: order.deliveryBoyImage,
                    width: 48,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$driverName has delivered your order.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Please rate $driverName services.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.deliveryPersonContact != null &&
                    order.deliveryPersonContact!.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse('tel:${order.deliveryPersonContact}'),
                      );
                    },
                    icon: const Icon(Icons.phone, color: AppColors.brand),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(5, (i) {
                final value = i + 1;
                final selected = _driverRating == value;
                return ChoiceChip(
                  label: Text('$value'),
                  selected: selected,
                  onSelected: (_) => setState(() => _driverRating = value),
                );
              }),
            ),
            TextField(
              controller: _driverComment,
              decoration: const InputDecoration(
                labelText: 'Comments about delivery',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit feedback'),
          ),
        ],
      ),
    );
  }
}
