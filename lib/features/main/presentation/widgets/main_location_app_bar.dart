import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../location/domain/entities/delivery_location_entity.dart';
class MainLocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainLocationAppBar({
    super.key,
    required this.location,
    this.onLocationTap,
    this.onSearch,
    this.onCart,
  });

  final DeliveryLocationEntity? location;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSearch;
  final VoidCallback? onCart;

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    final title = location?.locationTitle ?? 'Set delivery location';
    final subtitle = location?.locationSubtitle ?? '';

    return
      Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: AppColors.brand,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: InkWell(
              onTap: onLocationTap,
              child: Padding(
                padding: const EdgeInsets.only(top:10,left: 8, right: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.yourLocationLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: onSearch,
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: onCart,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
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
                      child: const Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
