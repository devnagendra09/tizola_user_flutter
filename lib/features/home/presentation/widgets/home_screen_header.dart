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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: pinColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deliver to',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: secondary,
                                size: 22,
                              ),
                            ],
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: secondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: iconColor,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => openCart(context),
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: iconColor,
                ),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
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
