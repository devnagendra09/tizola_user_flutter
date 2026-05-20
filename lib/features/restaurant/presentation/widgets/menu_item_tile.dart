import 'package:flutter/material.dart';

import '../../../../core/share/menu_item_share.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/menu_entity.dart';

class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.isBusy = false,
    this.shareSeoUrl,
    this.restaurantName,
  });

  final MenuItemEntity item;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isBusy;

  /// When set, shows share control (Android `img_share`).
  final String? shareSeoUrl;
  final String? restaurantName;

  bool get _canShare =>
      shareSeoUrl != null &&
      shareSeoUrl!.trim().isNotEmpty &&
      restaurantName != null;

  @override
  Widget build(BuildContext context) {
    final disabled = item.isSoldOut || !item.isRestaurantOpen || isBusy;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          onTap: null, // Can add tap for details if needed
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with badges
                Stack(
                  children: [
                    ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(12),
                      child: NetworkImageBox(
                        url: item.image,
                        width: 80,
                        height: 85,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Sold out overlay on image
                    if (item.isSoldOut)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: RotatedBox(
                              quarterTurns:4,
                              child: Text(
                                'SOLD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row with veg indicator
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: item.isVeg
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              item.isVeg ? Icons.circle : Icons.change_history,
                              size: 10,
                              color: item.isVeg ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Description
                      if (item.description != null && item.description!.isNotEmpty)
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Price section with offer badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandLite.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${item.applicablePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.brand,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (item.actualPrice > item.applicablePrice) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${item.actualPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${((item.actualPrice - item.applicablePrice) / item.actualPrice * 100).toInt()}% OFF',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Customizable badge
                      if (item.hasCustomizations)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune,
                                size: 10,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Customizable',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _MenuItemActions(
                  item: item,
                  disabled: disabled,
                  canShare: _canShare,
                  isBusy: isBusy,
                  shareSeoUrl: shareSeoUrl,
                  restaurantName: restaurantName,
                  onAdd: onAdd,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemActions extends StatelessWidget {
  const _MenuItemActions({
    required this.item,
    required this.disabled,
    required this.canShare,
    required this.isBusy,
    required this.shareSeoUrl,
    required this.restaurantName,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final MenuItemEntity item;
  final bool disabled;
  final bool canShare;
  final bool isBusy;
  final String? shareSeoUrl;
  final String? restaurantName;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (canShare) ...[
          IconButton(
            onPressed: isBusy
                ? null
                : () => MenuItemShare.share(
                      item: item,
                      restaurantName: restaurantName!,
                      seoUrl: shareSeoUrl!,
                    ),
            icon: const Icon(Icons.share_outlined),
            color: AppColors.brand,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Share',
          ),
          const SizedBox(height: 4),
        ],
        _QuantityControl(
          item: item,
          disabled: disabled,
          onAdd: onAdd,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.item,
    required this.disabled,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final MenuItemEntity item;
  final bool disabled;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (item.inCart) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconBtn(
              icon: Icons.remove,
              onTap: disabled ? null : onDecrement,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  '${item.quantity}',
                  key: ValueKey(item.quantity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            _IconBtn(
              icon: Icons.add,
              onTap: disabled ? null : onIncrement,
            ),
          ],
        ),
      );
    }

    final isSoldOut = item.isSoldOut;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          child: ElevatedButton(
            onPressed: disabled ? null : onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSoldOut ? Colors.grey.shade400 : AppColors.brand,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSoldOut) ...[
                  const Icon(Icons.add, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(isSoldOut ? 'SOLD' : 'ADD'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}