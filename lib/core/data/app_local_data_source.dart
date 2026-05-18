import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../../features/location/domain/entities/delivery_location_entity.dart';

abstract class AppLocalDataSource {
  String get deviceId;
  String? get latitude;
  String? get longitude;

  bool get hasSavedCoordinates;
  DeliveryLocationEntity? get savedDeliveryLocation;

  Future<void> ensureDeviceId();
  Future<void> saveLocation({required double lat, required double lng});
  Future<void> saveDeliveryLocation(DeliveryLocationEntity location);
  Future<void> clearLocation();
}

class AppLocalDataSourceImpl implements AppLocalDataSource {
  AppLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  String get deviceId => _prefs.getString(AppConstants.keyDeviceId) ?? '';

  @override
  String? get latitude => _prefs.getString(AppConstants.keyLatitude);

  @override
  String? get longitude => _prefs.getString(AppConstants.keyLongitude);

  @override
  bool get hasSavedCoordinates {
    final lat = latitude;
    final lng = longitude;
    return lat != null &&
        lat.isNotEmpty &&
        lng != null &&
        lng.isNotEmpty;
  }

  @override
  DeliveryLocationEntity? get savedDeliveryLocation {
    if (!hasSavedCoordinates) return null;
    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');
    final address = _prefs.getString(AppConstants.keyAddress);
    if (lat == null || lng == null || address == null || address.isEmpty) {
      return null;
    }
    return DeliveryLocationEntity(
      id: _prefs.getString(AppConstants.keyLocationId),
      latitude: lat,
      longitude: lng,
      address: address,
      addressType:
          _prefs.getString(AppConstants.keyAddressType) ??
          AppConstants.currentLocationLabel,
      doorNo: _prefs.getString(AppConstants.keyDoorNo),
      landmark: _prefs.getString(AppConstants.keyLandmark),
      addressDescription:
          _prefs.getString(AppConstants.keyAddressDescription),
    );
  }

  @override
  Future<void> ensureDeviceId() async {
    if (!_prefs.containsKey(AppConstants.keyDeviceId)) {
      await _prefs.setString(AppConstants.keyDeviceId, const Uuid().v4());
    }
  }

  @override
  Future<void> saveLocation({
    required double lat,
    required double lng,
  }) async {
    await _prefs.setString(AppConstants.keyLatitude, lat.toString());
    await _prefs.setString(AppConstants.keyLongitude, lng.toString());
  }

  @override
  Future<void> saveDeliveryLocation(DeliveryLocationEntity location) async {
    await saveLocation(lat: location.latitude, lng: location.longitude);
    await _prefs.setString(AppConstants.keyAddress, location.address);
    await _prefs.setString(AppConstants.keyAddressType, location.addressType);
    if (location.id != null) {
      await _prefs.setString(AppConstants.keyLocationId, location.id!);
    }
    if (location.doorNo != null) {
      await _prefs.setString(AppConstants.keyDoorNo, location.doorNo!);
    } else {
      await _prefs.remove(AppConstants.keyDoorNo);
    }
    if (location.landmark != null) {
      await _prefs.setString(AppConstants.keyLandmark, location.landmark!);
    } else {
      await _prefs.remove(AppConstants.keyLandmark);
    }
    if (location.addressDescription != null) {
      await _prefs.setString(
        AppConstants.keyAddressDescription,
        location.addressDescription!,
      );
    } else {
      await _prefs.remove(AppConstants.keyAddressDescription);
    }
  }

  @override
  Future<void> clearLocation() async {
    await _prefs.remove(AppConstants.keyLatitude);
    await _prefs.remove(AppConstants.keyLongitude);
    await _prefs.remove(AppConstants.keyAddress);
    await _prefs.remove(AppConstants.keyAddressType);
    await _prefs.remove(AppConstants.keyDoorNo);
    await _prefs.remove(AppConstants.keyLandmark);
    await _prefs.remove(AppConstants.keyAddressDescription);
    await _prefs.remove(AppConstants.keyLocationId);
  }
}
