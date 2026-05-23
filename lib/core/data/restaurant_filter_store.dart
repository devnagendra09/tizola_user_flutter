import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/catalog/domain/enums/restaurant_price_option.dart';
import '../../features/catalog/domain/enums/restaurant_sort_option.dart';

/// Android `AppController` sort / price / cuisines filters.
class RestaurantFilterStore {
  RestaurantFilterStore(this._prefs);

  static const _sortKey = 'sort_filter';
  static const _priceKey = 'price_filter';
  static const _cuisinesKey = 'cuisines_filter';

  final SharedPreferences _prefs;

  RestaurantSortOption? get sortOption =>
      RestaurantSortOption.fromApiValue(_prefs.getString(_sortKey));

  RestaurantPriceOption? get priceOption =>
      RestaurantPriceOption.fromApiValue(_prefs.getString(_priceKey));

  List<String> get cuisineIds {
    final raw = _prefs.getString(_cuisinesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  bool get hasActiveFilters =>
      sortOption != null || priceOption != null || cuisineIds.isNotEmpty;

  Future<void> setSortOption(RestaurantSortOption? option) async {
    if (option == null) {
      await _prefs.remove(_sortKey);
    } else {
      await _prefs.setString(_sortKey, option.apiValue);
    }
  }

  Future<void> setPriceOption(RestaurantPriceOption? option) async {
    if (option == null) {
      await _prefs.remove(_priceKey);
    } else {
      await _prefs.setString(_priceKey, option.apiValue);
    }
  }

  Future<void> setCuisineIds(List<String> ids) async {
    if (ids.isEmpty) {
      await _prefs.remove(_cuisinesKey);
    } else {
      await _prefs.setString(_cuisinesKey, jsonEncode(ids));
    }
  }

  Future<void> saveAll({
    RestaurantSortOption? sort,
    RestaurantPriceOption? price,
    required List<String> cuisines,
  }) async {
    await setSortOption(sort);
    await setPriceOption(price);
    await setCuisineIds(cuisines);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_sortKey);
    await _prefs.remove(_priceKey);
    await _prefs.remove(_cuisinesKey);
  }
}
