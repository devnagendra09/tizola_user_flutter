import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/catalog/domain/entities/order_entity.dart';
import '../../features/main/domain/entities/in_progress_order_entity.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/order_review_page.dart';
import '../../features/orders/presentation/pages/order_tracker_page.dart';

/// Android `MainActivity` track button → `OrderTrackerActivity` or `OrdersActivity`.
void openOrderFromTrackBar(
  BuildContext context,
  InProgressOrderEntity order,
) {
  // Android: track opens OrderTrackerActivity when live tracking is allowed.
  if (order.hasLiveTracking && !order.selfPickAccepted) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackerPage(refId: order.refId),
      ),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => OrderDetailPage(refId: order.refId),
    ),
  );
}

void openOrderDetail(BuildContext context, {required String refId}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => OrderDetailPage(refId: refId),
    ),
  );
}

void openOrderTracker(BuildContext context, {required String refId}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => OrderTrackerPage(refId: refId),
    ),
  );
}

void openOrderReview(BuildContext context, {required OrderEntity order}) {
  Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => OrderReviewPage(order: order),
    ),
  ).then((submitted) {
    if (!context.mounted || submitted != true) return;
    try {
      context.read<OrdersCubit>().loadOrders();
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback')),
    );
  });
}
