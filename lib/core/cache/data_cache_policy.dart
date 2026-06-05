/// TTL helper — skip API when in-memory data is still fresh (Zomato-style).
class DataCachePolicy {
  DataCachePolicy({this.ttl = const Duration(minutes: 10)});

  final Duration ttl;
  DateTime? _fetchedAt;

  bool get isFresh {
    final at = _fetchedAt;
    if (at == null) return false;
    return DateTime.now().difference(at) < ttl;
  }

  void markFresh() => _fetchedAt = DateTime.now();

  void invalidate() => _fetchedAt = null;
}
