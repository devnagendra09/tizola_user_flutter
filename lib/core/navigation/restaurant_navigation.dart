import 'package:flutter/material.dart';

import '../../features/catalog/domain/entities/restaurant_entity.dart';
import '../../features/main/presentation/cubit/main_cubit.dart';
import '../../features/restaurant/presentation/pages/restaurant_detail_page.dart';
import '../../injection_container.dart';

Future<void> openRestaurantDetail(
  BuildContext context,
  RestaurantEntity restaurant,
) async {
  final seoUrl = restaurant.seoUrl;
  if (seoUrl == null || seoUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restaurant link unavailable')),
    );
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RestaurantDetailPage(
        seoUrl: seoUrl,
        fallbackName: restaurant.name,
      ),
    ),
  );
  await sl<MainCubit>().refreshCartBadge();
}
