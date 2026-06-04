import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../auth/domain/entities/pending_feedback_entity.dart';
import '../../../catalog/domain/entities/order_entity.dart';
import '../pages/order_review_page.dart';

/// Android `ReviewOptionFragment` — prompt to rate last delivery.
Future<void> showReviewOptionDialog(
  BuildContext context, {
  required PendingFeedbackEntity feedback,
  required Future<void> Function(String refId) onSkip,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ReviewOptionDialog(
      feedback: feedback,
      onSkip: onSkip,
    ),
  );
}

class _ReviewOptionDialog extends StatelessWidget {
  const _ReviewOptionDialog({
    required this.feedback,
    required this.onSkip,
  });

  final PendingFeedbackEntity feedback;
  final Future<void> Function(String refId) onSkip;

  @override
  Widget build(BuildContext context) {
    final imageUrl = feedback.displayImage ?? feedback.deliveryBoyImage;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your order?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feedback.restaurantName ?? 'Your recent order',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkImageBox(
                    url: imageUrl,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              if (feedback.deliveryPersonName != null &&
                  feedback.deliveryPersonName!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Delivered by ${feedback.deliveryPersonName}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OrderReviewPage(
                          order: OrderEntity(
                            refId: feedback.refId,
                            restaurantName:
                                feedback.restaurantName ?? 'Restaurant',
                            selfPickAccepted:
                                feedback.selfPickAccepted == '1' ||
                                feedback.selfPickAccepted?.toLowerCase() ==
                                    'yes',
                          ),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brand,
                  ),
                  child: const Text('Leave feedback'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await onSkip(feedback.refId);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
