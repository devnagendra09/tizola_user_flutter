import 'dart:math';

class GeoUtils {
  /// Distance in km (same formula as Android NearByLocationActivity).
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  /// True when address is our lat/lng fallback (not a real street address).
  static bool isCoordinateOnlyAddress(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^-?\d+\.\d+,\s*-?\d+\.\d+$').hasMatch(trimmed);
  }
}
