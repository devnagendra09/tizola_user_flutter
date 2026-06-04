import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/maps/google_maps_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/repositories/location_repository.dart';

/// Android `MapsFragment` — pan map, pin at center, reverse-geocode, confirm.
class LocationMapPickerPage extends StatefulWidget {
  const LocationMapPickerPage({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialAddress,
    this.initialCity,
  });

  final double initialLatitude;
  final double initialLongitude;
  final String? initialAddress;
  final String? initialCity;

  @override
  State<LocationMapPickerPage> createState() => _LocationMapPickerPageState();
}

class _LocationMapPickerPageState extends State<LocationMapPickerPage> {
  final _repository = sl<LocationRepository>();
  final _mapKey = GlobalKey();
  GoogleMapController? _mapController;
  LatLng _center = LatLng(0, 0);
  String _address = '';
  String? _city;
  bool _geocoding = false;
  Timer? _geocodeDebounce;
  int _geocodeGeneration = 0;
  Size? _mapSize;

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.initialLatitude, widget.initialLongitude);
    _address = widget.initialAddress ?? '';
    _city = widget.initialCity;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocode(_center);
    });
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onCameraIdle() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 350), () {
      _resolveCenterAndGeocode();
    });
  }

  Future<void> _resolveCenterAndGeocode() async {
    final controller = _mapController;
    final mapSize = _mapSize;
    if (controller != null && mapSize != null && mapSize.width > 0) {
      try {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final latLng = await controller.getLatLng(
          ScreenCoordinate(
            x: (mapSize.width * dpr / 2).round(),
            y: (mapSize.height * dpr / 2).round(),
          ),
        );
        _center = latLng;
      } catch (_) {}
    }
    await _reverseGeocode(_center);
  }

  Future<void> _reverseGeocode(LatLng target) async {
    final generation = ++_geocodeGeneration;
    if (!mounted) return;
    setState(() {
      _geocoding = true;
      _center = target;
    });

    final result = await _repository.reverseGeocode(
      latitude: target.latitude,
      longitude: target.longitude,
    );

    if (!mounted || generation != _geocodeGeneration) return;

    setState(() {
      _geocoding = false;
      if (result.isSuccess && result.data != null) {
        _address = result.data!.address;
        _city = result.data!.city;
        _center = LatLng(result.data!.latitude, result.data!.longitude);
      } else {
        _address =
            '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}';
      }
    });

    if (result.isFailure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failure?.message ?? 'Could not update address',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirm() {
    if (_address.trim().isEmpty || _geocoding) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wait for the address to update, or try another spot'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      DeliveryLocationEntity(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address.trim(),
        city: _city,
        addressType: 'Home',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!GoogleMapsBootstrap.isReady) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm location')),
        body: const Center(
          child: Text('Map is not available on this device'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm location'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              key: _mapKey,
              builder: (context, constraints) {
                _mapSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 18,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                    ),
                    IgnorePointer(
                      child: Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppColors.brand.withValues(alpha: 0.95),
                      ),
                    ),
                    if (_geocoding)
                      const Positioned(
                        top: 12,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Updating address…'),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Material(
            elevation: 8,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _geocoding
                          ? 'Fetching address for pin location…'
                          : (_address.isEmpty
                              ? 'Move the map to pick your delivery point'
                              : _address),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _geocoding ? null : _confirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirm location'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
