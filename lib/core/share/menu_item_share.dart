import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../navigation/app_navigator.dart';
import '../../features/restaurant/domain/entities/menu_entity.dart';

/// Shares a menu item with a Tizola deep link (Android `VendorItemAddToCartAdapter.shareItem`).
class MenuItemShare {
  MenuItemShare._();

  static const String _sharePath = 'https://tizola.in/share';

  static Uri buildShareUri({
    required String seoUrl,
    required String itemId,
  }) {
    return Uri.parse('$_sharePath/$seoUrl/$itemId');
  }

  static String buildShareText({
    required MenuItemEntity item,
    required String restaurantName,
    required String seoUrl,
  }) {
    final link = buildShareUri(seoUrl: seoUrl, itemId: item.id).toString();
    final buffer = StringBuffer()
      ..writeln(
        '🍽️ Check out this delicious item from $restaurantName on Tizola!\n',
      )
      ..writeln('📱 ${item.name}');

    final description = item.description?.trim();
    if (description != null && description.isNotEmpty) {
      buffer.writeln('📝 $description');
    }

    buffer
      ..writeln('💰 ₹${item.applicablePrice.round()}')
      ..writeln('🚚 Fast Delivery Available\n')
      ..writeln('Get it delivered to your doorstep: $link');

    return buffer.toString();
  }

  static Future<void> share({
    required MenuItemEntity item,
    required String restaurantName,
    required String seoUrl,
  }) async {
    if (seoUrl.trim().isEmpty) {
      return;
    }

    try {
      await Share.share(
        buildShareText(
          item: item,
          restaurantName: restaurantName,
          seoUrl: seoUrl.trim(),
        ),
        subject: '${item.name} - Tizola',
      );
    } catch (_) {
      final context = appNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to share item')),
        );
      }
    }
  }
}
