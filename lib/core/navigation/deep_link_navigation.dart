import 'package:flutter/material.dart';

import '../../features/restaurant/presentation/pages/restaurant_detail_page.dart';
import '../../injection_container.dart';
import '../deeplink/deep_link_store.dart';

/// Opens a pending `https://tizola.in/share/{seoUrl}/{itemId}` link if one exists.
bool openPendingShareDeepLink(BuildContext context) {
  final payload = sl<DeepLinkStore>().takePending();
  if (payload == null) return false;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Loading shared item...')),
  );
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RestaurantDetailPage(
        seoUrl: payload.seoUrl,
        sharedItemId: payload.itemId,
      ),
    ),
  );
  return true;
}
