import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/menu_entity.dart';

/// Horizontal card for the Recommended strip — aligned with Android
/// `item_food_list_recommened.xml` (100dp image, compact footer, wrap height).
class RecommendedDishCard extends StatelessWidget {
  const RecommendedDishCard({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.isPending = false,
  });

  final MenuItemEntity item;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final disabled = item.isSoldOut || !item.isRestaurantOpen;
    final actionsLocked =
        disabled || isPending || (item.inCart && !item.isCartLineReady);
    final showStrike =
        item.actualPrice > 0 && item.actualPrice > item.applicablePrice;

    return SizedBox(
      width: 130,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: NetworkImageBox(
                  url: item.image,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      item.isVeg ? Icons.circle : Icons.change_history,
                      size: 10,
                      color: item.isVeg ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (showStrike) ...[
                      Text(
                        '₹${item.actualPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '₹${item.applicablePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brand,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.hasCustomizations)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                  child: Text(
                    'Customizable',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              _BottomActions(
                item: item,
                actionsLocked: actionsLocked,
                isPending: isPending,
                onAdd: onAdd,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.item,
    required this.actionsLocked,
    required this.isPending,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final MenuItemEntity item;
  final bool actionsLocked;
  final bool isPending;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (item.inCart) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MiniIconBtn(
              icon: Icons.remove,
              onTap: actionsLocked ? null : onDecrement,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: isPending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brand,
                      ),
                    )
                  : Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
            _MiniIconBtn(
              icon: Icons.add,
              onTap: actionsLocked ? null : onIncrement,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Center(
        child: SizedBox(
          height: 28,
          width: 72,
          child: ElevatedButton(
            onPressed: actionsLocked ? null : onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: item.isSoldOut ? Colors.grey : AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            child: isPending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(item.isSoldOut ? 'SOLD' : 'Add +'),
          ),
        ),
      ),
    );
  }
}

class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryBrand,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
