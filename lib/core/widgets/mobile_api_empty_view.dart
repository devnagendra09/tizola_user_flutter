import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';

/// Empty state for mobile API responses (image + message), similar to Android `emptyView`.
class MobileApiEmptyView extends StatelessWidget {
  const MobileApiEmptyView({
    super.key,
    required this.message,
    this.assetPath = AppAssets.noRestaurantFound,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final String message;
  final String assetPath;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 220,
            height: 190,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
