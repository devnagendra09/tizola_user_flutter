import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/menu_entity.dart';

/// Horizontal card for the Recommended strip (Android-style)
class RecommendedDishCard extends StatelessWidget {
  const RecommendedDishCard({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.isBusy = false,
  });

  final MenuItemEntity item;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final disabled = item.isSoldOut || !item.isRestaurantOpen || isBusy;

    return SizedBox(
      width: 148,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                child: NetworkImageBox(
                  url: item.image,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '₹${item.applicablePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brand,
                    fontSize: 13,
                  ),
                ),
              ),
            //  const Spacer(),
              if (item.hasCustomizations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Customizable',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              _BottomActions(
                item: item,
                disabled: disabled,
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
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MiniIconBtn(
              icon: Icons.remove,
              onTap: disabled ? null : onDecrement,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _MiniIconBtn(
              icon: Icons.add,
              onTap: disabled ? null : onIncrement,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: disabled ? null : onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: item.isSoldOut ? Colors.grey : AppColors.brand,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: Text(item.isSoldOut ? 'SOLD' : 'Add +'),
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
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
