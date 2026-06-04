import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/google_api_keys.dart';
import 'polyline_decoder.dart';

/// Google Directions API — Android `OrderTrackerActivity.getURL`.
class DirectionsService {
  DirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<LatLng>> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get<String>(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'sensor': 'false',
          'key': GoogleApiKeys.directions,
        },
      );

      final data = jsonDecode(response.data ?? '{}') as Map<String, dynamic>;
      if (data['status']?.toString() != 'OK') return [];

      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) return [];

      final route = routes.first as Map<String, dynamic>;

      final overview = route['overview_polyline'] as Map<String, dynamic>?;
      final overviewEncoded = overview?['points']?.toString() ?? '';
      if (overviewEncoded.isNotEmpty) {
        return decodeEncodedPolyline(overviewEncoded);
      }

      final legs = route['legs'] as List<dynamic>? ?? [];
      if (legs.isEmpty) return [];

      final steps = legs.first['steps'] as List<dynamic>? ?? [];
      final points = <LatLng>[];

      for (final step in steps) {
        final map = step as Map<String, dynamic>;
        final poly = map['polyline'] as Map<String, dynamic>?;
        final encoded = poly?['points']?.toString() ?? '';
        if (encoded.isEmpty) continue;
        points.addAll(decodeEncodedPolyline(encoded));
      }

      return points;
    } catch (_) {
      return [];
    }
  }
}
