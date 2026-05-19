import 'package:flutter/material.dart';

import '../../features/catalog/domain/entities/restaurant_entity.dart';
import '../../features/restaurant/presentation/pages/restaurant_detail_page.dart';

void openRestaurantDetail(BuildContext context, RestaurantEntity restaurant) {
  final seoUrl = restaurant.seoUrl;
  if (seoUrl == null || seoUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant link unavailable')),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RestaurantDetailPage(
        seoUrl: seoUrl,
        fallbackName: restaurant.name,
      ),
    ),
  );
}
