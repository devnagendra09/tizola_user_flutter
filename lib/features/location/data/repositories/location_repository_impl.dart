import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';
import '../models/delivery_location_mapper.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(
    this._appLocal,
    this._authLocal,
    this._remote,
  );

  final AppLocalDataSource _appLocal;
  final AuthLocalDataSource _authLocal;
  final LocationRemoteDataSource _remote;

  @override
  bool get hasSavedCoordinates => _appLocal.hasSavedCoordinates;

  @override
  DeliveryLocationEntity? get savedDeliveryLocation =>
      _appLocal.savedDeliveryLocation;

  @override
  Future<Result<List<DeliveryLocationEntity>>> fetchSavedAddresses() async {
    final token = _authLocal.accessToken;
    if (token == null || token.isEmpty) {
      return Result.success([]);
    }
    try {
      final list = await _remote.fetchCustomerAddresses(token);
      return Result.success(
        list.map(DeliveryLocationMapper.fromApi).toList(),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Result<List<DeliveryLocationEntity>>> searchPlaces(
    String query,
  ) async {
    if (query.trim().length < 3) {
      return Result.success([]);
    }
    try {
      final locations = await locationFromAddress(query);
      final results = <DeliveryLocationEntity>[];
      for (final loc in locations.take(6)) {
        final placemarks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        final place = placemarks.isNotEmpty ? placemarks.first : null;
        final line = _formatAddress(place);
        results.add(
          DeliveryLocationEntity(
            latitude: loc.latitude,
            longitude: loc.longitude,
            address: line.isNotEmpty ? line : query.trim(),
            addressType: AppConstants.currentLocationLabel,
            city: _cityFrom(place),
          ),
        );
      }
      return Result.success(results);
    } catch (_) {
      return Result.success([]);
    }
  }

  @override
  Future<Result<DeliveryLocationEntity>> resolveCurrentLocation() async {
    try {
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return Result.failure(
          const ValidationFailure('Location permission is required'),
        );
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return Result.failure(
          const ValidationFailure('Please turn on GPS'),
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return Result.success(await _geocodePosition(position));
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> selectDeliveryLocation(
    DeliveryLocationEntity location,
  ) async {
    await _appLocal.saveDeliveryLocation(location);
    return Result.success(null);
  }

  @override
  Future<Result<DeliveryLocationEntity>> resolveNearbyDeliveryLocation() async {
    try {
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return Result.failure(
          const ValidationFailure('Location permission is required'),
        );
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        return Result.failure(
          const ValidationFailure('Please turn on GPS to find your location'),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final token = _authLocal.accessToken;
      if (token != null && token.isNotEmpty) {
        final addresses = await _remote.fetchCustomerAddresses(token);
        for (final item in addresses) {
          final loc = DeliveryLocationMapper.fromApi(item);
          if (loc.latitude == 0 && loc.longitude == 0) continue;

          final km = GeoUtils.distanceKm(
            position.latitude,
            position.longitude,
            loc.latitude,
            loc.longitude,
          );

          if (km <= AppConstants.nearbyAddressKmThreshold) {
            await _appLocal.saveDeliveryLocation(loc);
            return Result.success(loc);
          }
        }
      }

      final geocoded = await _geocodePosition(position);
      await _appLocal.saveDeliveryLocation(geocoded);
      return Result.success(geocoded);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  Future<DeliveryLocationEntity> _geocodePosition(Position position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.isNotEmpty ? placemarks.first : null;
    final line = _formatAddress(place);
    final address = line.isNotEmpty
        ? line
        : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';

    return DeliveryLocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
      addressType: AppConstants.currentLocationLabel,
      city: _cityFrom(place),
    );
  }

  String _formatAddress(Placemark? p) {
    if (p == null) return '';
    final parts = <String>[
      if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
      if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
      if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
      if ((p.postalCode ?? '').trim().isNotEmpty) p.postalCode!.trim(),
    ];
    return parts.join(', ');
  }

  String _cityFrom(Placemark? p) {
    if (p == null) return '';
    return (p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '')
        .trim();
  }

  @override
  Future<Result<void>> persistDeliveryLocation({
    required double latitude,
    required double longitude,
    required String address,
    required String city,
    required String doorNo,
    required String landmark,
    required String addressDescription,
    required String addressType,
    String? addressTypeText,
    String? id,
  }) async {
    final token = _authLocal.accessToken;
    final hasToken = token != null && token.isNotEmpty;

    if (hasToken) {
      try {
        final body = <String, String>{
          'address_type': addressType,
          'address': address,
          'door_no': doorNo,
          'address_description': addressDescription,
          'landmark': landmark,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'city': city.isEmpty ? '—' : city,
          'access_token': token,
        };
        if (id != null && id.isNotEmpty) {
          body['id'] = id;
        }
        if (addressTypeText != null && addressTypeText.trim().isNotEmpty) {
          body['address_type_text'] = addressTypeText.trim();
        }
        await _remote.addCustomerAddress(body);
      } catch (e) {
        return Result.failure(
          ServerFailure(e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    await _appLocal.saveDeliveryLocation(
      DeliveryLocationEntity(
        id: id,
        latitude: latitude,
        longitude: longitude,
        address: address,
        addressType: addressType,
        doorNo: doorNo.isEmpty ? null : doorNo,
        landmark: landmark.isEmpty ? null : landmark,
        addressDescription:
            addressDescription.isEmpty ? null : addressDescription,
        addressTypeText: addressTypeText,
        city: city.isEmpty ? null : city,
      ),
    );
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    final token = _authLocal.accessToken;
    if (token == null || token.isEmpty) {
      return Result.failure(const ValidationFailure('Login required'));
    }
    try {
      await _remote.deleteCustomerAddress(id: id, accessToken: token);
      final saved = _appLocal.savedDeliveryLocation;
      if (saved?.id == id) {
        await _appLocal.clearLocation();
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerFailure(e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }
}
