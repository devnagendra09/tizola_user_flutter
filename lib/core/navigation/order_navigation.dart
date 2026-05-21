import 'package:flutter/material.dart';

import '../../features/main/domain/entities/in_progress_order_entity.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/order_tracker_page.dart';

/// Android `MainActivity` track button → `OrderTrackerActivity` or `OrdersActivity`.
void openOrderFromTrackBar(
  BuildContext context,
  InProgressOrderEntity order,
) {
  // Live map screen (Android OrderTrackerActivity); detail if self-pick only.
  if (order.hasLiveTracking && !order.selfPickAccepted) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackerPage(refId: order.refId),
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(refId: order.refId),
      ),
    );
  }
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
