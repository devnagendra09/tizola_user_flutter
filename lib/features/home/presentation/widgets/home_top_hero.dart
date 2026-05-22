import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../location/domain/entities/delivery_location_entity.dart';
import 'home_screen_header.dart';
import 'home_search_bar.dart';

/// Top home hero — gradient background with header + search.
class HomeTopHero extends StatelessWidget {
  const HomeTopHero({
    super.key,
    required this.location,
    required this.onLocationTap,
    this.cartItemCount = 0,
  });

  final DeliveryLocationEntity? location;
  final VoidCallback onLocationTap;
  final int cartItemCount;

  static const double _heroHeight = 200;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: _heroHeight + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _GradientBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white10,
                    Colors.white.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: topPadding,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeScreenHeader(
                  location: location,
                  onLocationTap: onLocationTap,
                  cartItemCount: cartItemCount,
                  lightForeground: true,
                ),
                const HomeSearchBar(),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF023A85),
            AppColors.brand,
            AppColors.secondaryBrand,
            AppColors.secondaryBrand,
         //   Color(0xFF9BB8EB),
            AppColors.brand,
            AppColors.brand,

           // Color(0xFF9BB8EB),
          ],
          stops: [0.0, 0.22, 0.45, 0.65, 1.0, 1.0],
        ),
      ),
    );
  }
}
