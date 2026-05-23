import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/veg_filter_chip.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';

/// Android home row: Veg / Non-veg chips + filter icon (`fragment_main` `filter`).
class HomeFilterChipsRow extends StatelessWidget {
  const HomeFilterChipsRow({
    super.key,
    required this.foodFilter,
    required this.hasActiveFilters,
    required this.onAllTap,
    required this.onVegTap,
    required this.onNonVegTap,
    required this.onFilterTap,
  });

  final RestaurantFoodFilter foodFilter;
  final bool hasActiveFilters;
  final VoidCallback onAllTap;
  final VoidCallback onVegTap;
  final VoidCallback onNonVegTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final allSelected = foodFilter == RestaurantFoodFilter.all;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: hasActiveFilters
                ? AppColors.brand.withValues(alpha: 0.12)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: hasActiveFilters
                    ? AppColors.brand
                    : Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Badge(
                  isLabelVisible: hasActiveFilters,
                  backgroundColor: AppColors.brand,
                  smallSize: 8,
                  child: Icon(
                    Icons.tune,
                    size: 22,
                    color: hasActiveFilters
                        ? AppColors.brand
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
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
    this.onTap,
  });

  final String label;
  final bool selected;
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
