import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/restaurant_repository.dart';

/// Android `RestaurantAboutFragment`.
class RestaurantAboutTab extends StatefulWidget {
  const RestaurantAboutTab({super.key, required this.seoUrl});

  final String seoUrl;

  @override
  State<RestaurantAboutTab> createState() => _RestaurantAboutTabState();
}

class _RestaurantAboutTabState extends State<RestaurantAboutTab> {
  var _loading = true;
  String? _error;
  var _description = '';
  var _address = '';
  var _hours = <String>[];
  LatLng? _mapPosition;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await sl<RestaurantRepository>().getAbout(
      seoUrl: widget.seoUrl,
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failure?.message ?? 'Failed to load';
      });
      return;
    }
    final about = result.data!;
    setState(() {
      _loading = false;
      _description = about.description;
      _address = about.displayAddress;
      _hours = about.businessHours
          .map((h) => '${h.weekName} ${h.timings}')
          .toList();
      if (about.hasMap) {
        _mapPosition = LatLng(about.latitude!, about.longitude!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_description.isEmpty && _address.isEmpty) {
      return const MobileApiEmptyView(message: 'No information available');
    }

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_description.isNotEmpty) ...[
            const Text(
              'About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_description, style: TextStyle(color: Colors.grey.shade800)),
            const SizedBox(height: 16),
          ],
          if (_address.isNotEmpty) ...[
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_address),
            const SizedBox(height: 16),
          ],
          if (_hours.isNotEmpty) ...[
            const Text(
              'Hours',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._hours.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            ),
          ],
          if (_mapPosition != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _mapPosition!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(markerId: const MarkerId('store'), position: _mapPosition!),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
