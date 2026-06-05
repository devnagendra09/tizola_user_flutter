import 'package:hive_flutter/hive_flutter.dart';

import '../../features/cart/domain/entities/cart_entity.dart';
import '../../features/catalog/domain/entities/order_entity.dart';
import '../../features/home/presentation/cubit/home_state.dart';
import '../../features/location/domain/entities/delivery_location_entity.dart';
import '../../features/orders/presentation/cubit/orders_state.dart';
import '../data/app_local_data_source.dart';
import 'cache_json_codec.dart';

/// Disk cache (Hive) — survives app restart on Android + iOS.
class HiveLocalCache {
  HiveLocalCache(this._appLocal);

  static const _boxName = 'tizola_hive_cache';
  static const _homePrefix = 'home_';
  static const _ordersUpcomingKey = 'orders_upcoming';
  static const _ordersPastKey = 'orders_past';
  static const _savedAddressesKey = 'saved_addresses';
  static const _cartKey = 'cart_snapshot';
  static const _recentSearchesKey = 'recent_searches';

  final AppLocalDataSource _appLocal;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
    _ready = true;
  }

  Box<dynamic> get _box {
    if (!_ready || !Hive.isBoxOpen(_boxName)) {
      throw StateError('HiveLocalCache.init() must run before use');
    }
    return Hive.box<dynamic>(_boxName);
  }

  String locationScope() {
    final lat = double.tryParse(_appLocal.latitude ?? '');
    final lng = double.tryParse(_appLocal.longitude ?? '');
    if (lat == null || lng == null) return 'no_location';
    return '${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}';
  }

  Future<void> write(
    String key,
    Map<String, dynamic> data, {
    Duration ttl = const Duration(minutes: 30),
  }) async {
    await _box.put(key, {
      'savedAt': DateTime.now().toIso8601String(),
      'ttlMinutes': ttl.inMinutes,
      'data': data,
    });
  }

  Map<String, dynamic>? read(
    String key, {
    Duration? maxAge,
  }) {
    final raw = _box.get(key);
    if (raw is! Map) return null;

    final savedAt = DateTime.tryParse(raw['savedAt']?.toString() ?? '');
    if (savedAt == null) return null;

    final ttlMinutes = raw['ttlMinutes'] as int? ?? 30;
    final ageLimit = maxAge ?? Duration(minutes: ttlMinutes);
    if (DateTime.now().difference(savedAt) > ageLimit) {
      return null;
    }

    final data = raw['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // --- Home ---

  Future<void> saveHome(HomeState state) async {
    if (state.restaurants.isEmpty) return;
    await write(
      '$_homePrefix${locationScope()}',
      CacheJsonCodec.homeStateToJson(state),
      ttl: const Duration(minutes: 20),
    );
  }

  HomeState? readHome(HomeState base) {
    final data = read('$_homePrefix${locationScope()}');
    if (data == null) return null;
    return CacheJsonCodec.homeStateFromJson(data, base);
  }

  Future<void> clearHomeForCurrentLocation() async {
    await _box.delete('$_homePrefix${locationScope()}');
  }

  // --- Orders ---

  Future<void> saveOrdersUpcoming({
    required List<OrderEntity> orders,
    required int totalPages,
    String? emptyMessage,
  }) async {
    await write(
      _ordersUpcomingKey,
      CacheJsonCodec.ordersPageToJson(
        orders: orders,
        totalPages: totalPages,
        emptyMessage: emptyMessage,
      ),
      ttl: const Duration(minutes: 15),
    );
  }

  Future<void> saveOrdersPast({
    required List<OrderEntity> orders,
    required int totalPages,
    String? emptyMessage,
  }) async {
    await write(
      _ordersPastKey,
      CacheJsonCodec.ordersPageToJson(
        orders: orders,
        totalPages: totalPages,
        emptyMessage: emptyMessage,
      ),
      ttl: const Duration(hours: 2),
    );
  }

  OrdersState? readOrdersState(OrdersState base) {
    final upcoming = read(_ordersUpcomingKey);
    final past = read(_ordersPastKey);
    if (upcoming == null && past == null) return null;
    return CacheJsonCodec.applyOrdersCache(
      base,
      upcoming ?? {'orders': [], 'totalPages': 1},
      past ?? {'orders': [], 'totalPages': 1},
    );
  }

  // --- Saved addresses ---

  Future<void> saveAddresses(List<DeliveryLocationEntity> addresses) async {
    await write(
      _savedAddressesKey,
      {
        'items': addresses
            .map(CacheJsonCodec.deliveryLocationToJson)
            .toList(growable: false),
      },
      ttl: const Duration(days: 7),
    );
  }

  List<DeliveryLocationEntity>? readAddresses() {
    final data = read(
      _savedAddressesKey,
      maxAge: const Duration(days: 7),
    );
    if (data == null) return null;
    return (data['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map(
          (e) => CacheJsonCodec.deliveryLocationFromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  // --- Cart ---

  Future<void> saveCart(CartEntity cart) async {
    if (cart.isEmpty) {
      await _box.delete(_cartKey);
      return;
    }
    await write(
      _cartKey,
      CacheJsonCodec.cartToJson(cart),
      ttl: const Duration(hours: 12),
    );
  }

  CartEntity? readCart() {
    final data = read(_cartKey, maxAge: const Duration(hours: 12));
    if (data == null) return null;
    return CacheJsonCodec.cartFromJson(data);
  }

  Future<void> clearCart() => _box.delete(_cartKey);

  // --- Recent searches ---

  List<String> readRecentSearches() {
    final raw = _box.get(_recentSearchesKey);
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    final current = readRecentSearches()
        .where((e) => e.toLowerCase() != trimmed.toLowerCase())
        .toList();
    final next = [trimmed, ...current].take(8).toList();
    await _box.put(_recentSearchesKey, next);
  }

  // --- Session ---

  Future<void> clearUserSessionCache() async {
    await _box.delete(_ordersUpcomingKey);
    await _box.delete(_ordersPastKey);
    await _box.delete(_savedAddressesKey);
    await _box.delete(_cartKey);
  }

  Future<void> clearAll() => _box.clear();
}
