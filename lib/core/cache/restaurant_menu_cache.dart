import '../../features/restaurant/domain/entities/menu_entity.dart';

/// In-memory menu cache — instant reopen of same restaurant during a session.
class RestaurantMenuCache {
  RestaurantMenuCache({this.ttl = const Duration(minutes: 15)});

  final Duration ttl;
  final _menus = <String, List<MenuCategoryEntity>>{};
  final _fetchedAt = <String, DateTime>{};

  String _key(String seoUrl, String foodFilter) => '$seoUrl::$foodFilter';

  List<MenuCategoryEntity>? read(String seoUrl, String foodFilter) {
    final key = _key(seoUrl, foodFilter);
    final at = _fetchedAt[key];
    if (at == null) return null;
    if (DateTime.now().difference(at) > ttl) {
      _menus.remove(key);
      _fetchedAt.remove(key);
      return null;
    }
    return _menus[key];
  }

  void save(String seoUrl, String foodFilter, List<MenuCategoryEntity> menu) {
    if (menu.isEmpty) return;
    final key = _key(seoUrl, foodFilter);
    _menus[key] = menu;
    _fetchedAt[key] = DateTime.now();
  }

  void invalidate(String seoUrl) {
    _menus.removeWhere((k, _) => k.startsWith('$seoUrl::'));
    _fetchedAt.removeWhere((k, _) => k.startsWith('$seoUrl::'));
  }
}
