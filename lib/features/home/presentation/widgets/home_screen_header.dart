import 'package:flutter/material.dart';

import '../../../../core/navigation/cart_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../location/domain/entities/delivery_location_entity.dart';

/// Top header: Deliver to + location, notifications, cart (reference home UI).
class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({
    super.key,
    required this.location,
    required this.onLocationTap,
    this.cartItemCount = 0,
    this.lightForeground = false,
  });

  final DeliveryLocationEntity? location;
  final VoidCallback onLocationTap;
  final int cartItemCount;

  /// White icons/text on gradient or dark image overlay.
  final bool lightForeground;

  @override
  Widget build(BuildContext context) {
    final title = location?.locationTitle ?? 'Set location';
    final subtitle = location?.locationSubtitle ?? '';
    final primary = lightForeground ? Colors.white : Colors.black87;
    final secondary = lightForeground ? Colors.white70 : Colors.grey.shade600;
    final iconColor = lightForeground ? Colors.white : Colors.grey.shade800;
    final pinColor = lightForeground ? Colors.white : AppColors.brand;
    final actionBackground = lightForeground
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.grey.shade100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  //  Icon(Icons.location_on_outlined, color: pinColor, size: 22),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: pinColor, size: 15),
                              Text(
                                'Your Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _HeaderActionButton(
                icon: Icons.shopping_cart_outlined,
                iconColor: iconColor,
                backgroundColor: actionBackground,
                tooltip: 'Cart',
                onTap: () => openCart(context),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: -4,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 13,
                      minHeight: 13,
                    ),
                    child: Text(
                      cartItemCount > 9 ? '9+' : '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: tooltip,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                  icon, color: iconColor, size: 17
              ),
            ),
          ),
        ),
      ),
    );
  }
}
