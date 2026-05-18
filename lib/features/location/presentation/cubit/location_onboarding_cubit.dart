import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/repositories/location_repository.dart';
import 'location_onboarding_state.dart';

class LocationOnboardingCubit extends Cubit<LocationOnboardingState> {
  LocationOnboardingCubit(this._repository)
      : super(const LocationOnboardingState());

  final LocationRepository _repository;

  Future<void> useCurrentLocation() async {
    emit(state.copyWith(status: LocationOnboardingStatus.resolving, clearError: true));

    final permission = await _requestLocationPermission();
    if (!permission) {
      emit(
        state.copyWith(
          status: LocationOnboardingStatus.permissionDenied,
          errorMessage:
              'Location permission is required to show nearby restaurants.',
        ),
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(
        state.copyWith(
          status: LocationOnboardingStatus.serviceDisabled,
          errorMessage: 'Please turn on device location (GPS) and try again.',
        ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final addressLine = _formatAddress(place);
      final city = _cityFrom(place);

      emit(
        state.copyWith(
          status: LocationOnboardingStatus.ready,
          draft: LocationDraft(
            latitude: position.latitude,
            longitude: position.longitude,
            addressLine: addressLine.isEmpty
                ? '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'
                : addressLine,
            city: city.isEmpty ? '—' : city,
          ),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationOnboardingStatus.failure,
          errorMessage: 'Could not read your location. Please try again.',
        ),
      );
    }
  }

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  String _formatAddress(Placemark? p) {
    if (p == null) return '';
    final parts = <String>[
      if ((p.name ?? '').trim().isNotEmpty) p.name!.trim(),
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

  Future<void> saveToServerAndLocal({
    required String doorNo,
    required String landmark,
    required String addressDescription,
    required String addressType,
    String? addressTypeText,
  }) async {
    final draft = state.draft;
    if (draft == null) return;

    emit(state.copyWith(status: LocationOnboardingStatus.saving, clearError: true));

    final result = await _repository.persistDeliveryLocation(
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.addressLine,
      city: draft.city,
      doorNo: doorNo,
      landmark: landmark,
      addressDescription: addressDescription,
      addressType: addressType,
      addressTypeText: addressTypeText,
    );

    if (result.isSuccess) {
      emit(
        state.copyWith(
          status: LocationOnboardingStatus.saved,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: LocationOnboardingStatus.ready,
          errorMessage: result.failure?.message ?? 'Failed to save address',
        ),
      );
    }
  }

  /// Opens platform location settings (Android / iOS).
  Future<void> openDeviceLocationSettings() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Geolocator.openLocationSettings();
    }
  }
}
