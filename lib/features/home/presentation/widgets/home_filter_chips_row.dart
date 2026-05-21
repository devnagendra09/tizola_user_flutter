import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/veg_filter_chip.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';

class HomeFilterChipsRow extends StatelessWidget {
  const HomeFilterChipsRow({
    super.key,
    required this.foodFilter,
    required this.onAllTap,
    required this.onVegTap,
    required this.onNonVegTap,
    this.onSortTap,
  });

  final RestaurantFoodFilter foodFilter;
  final VoidCallback onAllTap;
  final VoidCallback onVegTap;
  final VoidCallback onNonVegTap;
  final VoidCallback? onSortTap;

  @override
  Widget build(BuildContext context) {
    final allSelected = foodFilter == RestaurantFoodFilter.all;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterPill(
            label: 'All',
            selected: allSelected,
            onTap: onAllTap,
          ),
          const SizedBox(width: 8),
          VegFilterChip(
            isVeg: true,
            selected: foodFilter == RestaurantFoodFilter.veg,
            onTap: onVegTap,
          ),
          const SizedBox(width: 8),
          VegFilterChip(
            isVeg: false,
            selected: foodFilter == RestaurantFoodFilter.nonVeg,
            onTap: onNonVegTap,
          ),
          const SizedBox(width: 28),
          // _FilterPill(
          //   label: 'Fast Delivery',
          //   icon: Icons.bolt,
          //   iconColor: AppColors.brand,
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Fast delivery filter coming soon')),
          //     );
          //   },
          // ),
         // const SizedBox(width: 8),

          _FilterPill(
            label: 'Sort',
            icon: Icons.swap_vert,
            onTap: onSortTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sort options coming soon')),
                  );
                },
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    this.selected = false,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.brand : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : (iconColor ?? Colors.grey.shade700),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            if (label == 'Sort') ...[
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
