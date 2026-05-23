import 'package:flutter/material.dart';

/// Android `FilterItemFragment` Sort tab → `m_sort` in `mobile_filters`.
enum RestaurantSortOption {
  recommended('recommended', 'Recommended', Icons.thumb_up_outlined),
  popular('popular', 'Most popular', Icons.trending_up),
  newArrivals('new_arrivals', 'New arrivals', Icons.fiber_new_outlined),
  rating('ratting', 'Rating', Icons.star_outline),
  deliveryTime('delivery_time', 'Delivery time', Icons.schedule_outlined);

  const RestaurantSortOption(this.apiValue, this.label, this.icon);

  final String apiValue;
  final String label;
  final IconData icon;

  static RestaurantSortOption? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final option in RestaurantSortOption.values) {
      if (option.apiValue == value) return option;
    }
    return null;
  }
}
