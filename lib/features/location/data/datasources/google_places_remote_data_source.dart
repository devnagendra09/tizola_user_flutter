import 'package:dio/dio.dart';

import '../../../../core/constants/google_api_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/entities/place_prediction_entity.dart';

/// Google Places + Geocoding REST (Android `Places` SDK + `geocode/json`).
class GooglePlacesRemoteDataSource {
  GooglePlacesRemoteDataSource() : _dio = _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (_) => true,
      ),
    );
  }

  /// Android `Autocomplete.IntentBuilder` with `setCountry("IN")`.
  Future<List<PlacePredictionEntity>> autocomplete(String input) async {
    final trimmed = input.trim();
    if (trimmed.length < 2) return [];

    final response = await _dio.get<dynamic>(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'input': trimmed,
        'key': GoogleApiKeys.places,
        'components': 'country:in',
        'language': 'en',
      },
    );

    final data = _asMap(response.data);
    if (data == null || data['status'] != 'OK') {
      if (data?['status'] == 'ZERO_RESULTS') return [];
      return [];
    }

    final predictions = data['predictions'] as List<dynamic>? ?? [];
    return predictions.map((raw) {
      final item = raw as Map<String, dynamic>;
      final structured =
          item['structured_formatting'] as Map<String, dynamic>?;
      return PlacePredictionEntity(
        placeId: item['place_id']?.toString() ?? '',
        description: item['description']?.toString() ?? '',
        primaryText: structured?['main_text']?.toString(),
        secondaryText: structured?['secondary_text']?.toString(),
      );
    }).where((p) => p.placeId.isNotEmpty).toList();
  }

  /// Android `Autocomplete.getPlaceFromIntent` → lat/lng + address.
  Future<DeliveryLocationEntity> placeDetails(String placeId) async {
    final response = await _dio.get<dynamic>(
      'https://maps.googleapis.com/maps/api/place/details/json',
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'place_id': placeId,
        'fields': 'geometry,formatted_address,name,address_component',
        'key': GoogleApiKeys.places,
      },
    );

    final data = _asMap(response.data);
    if (data == null || data['status'] != 'OK') {
      throw ServerFailure(
        data?['error_message']?.toString() ?? 'Place details failed',
      );
    }

    final result = data['result'] as Map<String, dynamic>? ?? {};
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      throw const ServerFailure('Place has no coordinates');
    }

    final formatted = result['formatted_address']?.toString() ??
        result['name']?.toString() ??
        '';
    final components =
        result['address_components'] as List<dynamic>? ?? [];

    return DeliveryLocationEntity(
      latitude: lat,
      longitude: lng,
      address: formatted,
      city: _cityFromComponents(components),
    );
  }

  /// Android `GetDeviceLocationActivity` geocode/json with places key.
  Future<DeliveryLocationEntity> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<dynamic>(
      'https://maps.googleapis.com/maps/api/geocode/json',
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'latlng': '$latitude,$longitude',
        'key': GoogleApiKeys.geocoder,
        'language': 'en',
      },
    );

    final data = _asMap(response.data);
    if (data == null || data['status'] != 'OK') {
      throw const ServerFailure('Unable to find address for this point');
    }

    final results = data['results'] as List<dynamic>? ?? [];
    if (results.isEmpty) {
      throw const ServerFailure('No address found');
    }

    final first = results.first as Map<String, dynamic>;
    final formatted = first['formatted_address']?.toString() ??
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    final components = first['address_components'] as List<dynamic>? ?? [];

    return DeliveryLocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: formatted,
      city: _cityFromComponents(components),
    );
  }

  String _cityFromComponents(List<dynamic> components) {
    for (final raw in components) {
      final c = raw as Map<String, dynamic>;
      final types = (c['types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      if (types.contains('locality') ||
          types.contains('administrative_area_level_2')) {
        return c['long_name']?.toString() ?? '';
      }
    }
    for (final raw in components) {
      final c = raw as Map<String, dynamic>;
      final types = (c['types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      if (types.contains('administrative_area_level_1')) {
        return c['long_name']?.toString() ?? '';
      }
    }
    return '';
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
