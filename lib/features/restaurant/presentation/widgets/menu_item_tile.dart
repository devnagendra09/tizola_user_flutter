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
    this.isPending = false,
    this.shareSeoUrl,
    this.restaurantName,
  });

  final MenuItemEntity item;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// True while this item's cart API call is in flight (other items stay interactive).
  final bool isPending;

  /// When set, shows share control (Android `img_share`).
  final String? shareSeoUrl;
  final String? restaurantName;

  bool get _canShare =>
      shareSeoUrl != null &&
      shareSeoUrl!.trim().isNotEmpty &&
      restaurantName != null;

  @override
  Widget build(BuildContext context) {
    final disabled = item.isSoldOut || !item.isRestaurantOpen;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          onTap: null, // Can add tap for details if needed
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandLite.withOpacity(0.2),
                  const Color(0xFFFDFDFD),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.06),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
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
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [

                          NetworkImageBox(
                            url: item.image,
                            width: 92,
                            height: 96,
                            fit: BoxFit.cover,
                          ),

                          /// Gradient Overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// Bestseller badge
                          // Positioned(
                          //   left: 6,
                          //   top: 6,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 6,
                          //       vertical: 3,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: Colors.orange,
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //     child: const Text(
                          //       "BESTSELLER",
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 8,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
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
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.brand.withOpacity(0.15),
                                  AppColors.brand.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₹${item.applicablePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.brand,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (item.actualPrice > item.applicablePrice) ...[
                            const SizedBox(width: 4),
                            Text(
                              '₹${item.actualPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.red.shade500,
                                fontSize: 12,
                              ),
                            ),

                            // Container(
                            //   margin: const EdgeInsets.only(left: 4),
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 6,
                            //     vertical: 2,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: Colors.green.withValues(alpha: 0.1),
                            //     borderRadius: BorderRadius.circular(4),
                            //   ),
                            //   child: Text(
                            //     '${((item.actualPrice - item.applicablePrice) / item.actualPrice * 100).toInt()}% OFF',
                            //     style: const TextStyle(
                            //       fontSize: 9,
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.green,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Customizable badge
                      if (!item.hasCustomizations)
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
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Customizable',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width:5 ),
                _MenuItemActions(
                  item: item,
                  disabled: disabled,
                  canShare: _canShare,
                  isPending: isPending,
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
    required this.isPending,
    required this.shareSeoUrl,
    required this.restaurantName,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final MenuItemEntity item;
  final bool disabled;
  final bool canShare;
  final bool isPending;
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
            onPressed: isPending
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
          _QuantityControl(
            item: item,
            disabled: disabled,
            isPending: isPending,
            onAdd: onAdd,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
        ],

      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.item,
    required this.disabled,
    required this.isPending,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final MenuItemEntity item;
  final bool disabled;
  final bool isPending;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  bool get _actionsLocked =>
      disabled || isPending || (item.inCart && !item.isCartLineReady);

  @override
  Widget build(BuildContext context) {
    if (item.inCart) {
      return _CartActionShell(
        isPending: isPending,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brand,
                AppColors.brand.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                icon: Icons.remove,
                onTap: _actionsLocked ? null : onDecrement,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: isPending
                      ? const SizedBox(
                          key: ValueKey('qty-loader'),
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '${item.quantity}',
                          key: ValueKey(item.quantity),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              _IconBtn(
                icon: Icons.add,
                onTap: _actionsLocked ? null : onIncrement,
              ),
            ],
          ),
        ),
      );
    }

    final isSoldOut = item.isSoldOut;
    return _CartActionShell(
      isPending: isPending,
      child: SizedBox(
        height: 38,
        child: ElevatedButton(
          onPressed: _actionsLocked ? null : onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.brand,
            elevation: 1,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSoldOut ? Colors.grey.shade300 : AppColors.brand,
                width: 1,
              ),
            ),
          ),
          child: isPending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSoldOut) ...[
                      const Icon(Icons.add, size: 12),
                      const SizedBox(width: 2),
                    ],
                    Text(isSoldOut ? 'SOLD' : 'ADD',style: TextStyle(fontSize: 14),),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CartActionShell extends StatelessWidget {
  const _CartActionShell({
    required this.isPending,
    required this.child,
  });

  final bool isPending;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isPending ? 0.85 : 1,
      child: child,
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