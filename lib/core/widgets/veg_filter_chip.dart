import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'food_type_indicator.dart';

/// Veg / Non-veg filter chip matching Android `fragment_main` / `fragment_restaurant_item`.
class VegFilterChip extends StatelessWidget {
  const VegFilterChip({
    super.key,
    required this.isVeg,
    required this.selected,
    required this.onTap,
  });

  final bool isVeg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isVeg ? AppColors.vegGreen : AppColors.error;
    final fillColor = selected
        ? (isVeg ? AppColors.vegLite : AppColors.nonVegLite)
        : AppColors.splash;
    final labelColor = isVeg ? AppColors.vegGreen : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FoodTypeIndicator(isVeg: isVeg, size: 15),
            const SizedBox(width: 4),
            Text(
              isVeg ? 'Veg' : 'Non-veg',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.close, size: 15, color: AppColors.obText),
            ],
          ],
        ),
      ),
    );
  }
}
