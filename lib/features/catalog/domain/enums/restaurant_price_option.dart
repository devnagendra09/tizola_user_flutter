import 'package:flutter/material.dart';

/// Android `FilterItemFragment` Price tab → `m_price` in `mobile_filters`.
enum RestaurantPriceOption {
  lowToHigh('low_to_high', 'Cost (Low to High)', Icons.arrow_upward),
  highToLow('high_to_low', 'Cost (High to Low)', Icons.arrow_downward);

  const RestaurantPriceOption(this.apiValue, this.label, this.icon);

  final String apiValue;
  final String label;
  final IconData icon;

  static RestaurantPriceOption? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final option in RestaurantPriceOption.values) {
      if (option.apiValue == value) return option;
    }
    return null;
  }
}
