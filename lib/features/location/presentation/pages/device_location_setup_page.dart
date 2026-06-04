import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_map_picker_page.dart';
import 'place_search_page.dart';

/// Android `GetDeviceLocationActivity` — map/search pick + address form, then home.
class DeviceLocationSetupPage extends StatefulWidget {
  const DeviceLocationSetupPage({super.key});

  @override
  State<DeviceLocationSetupPage> createState() => _DeviceLocationSetupPageState();
}

class _DeviceLocationSetupPageState extends State<DeviceLocationSetupPage> {
  final _repo = sl<LocationRepository>();
  final _doorNo = TextEditingController();
  final _landmark = TextEditingController();
  final _description = TextEditingController();
  final _otherLabel = TextEditingController();

  DeliveryLocationEntity? _draft;
  String _addressType = 'Home';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _doorNo.dispose();
    _landmark.dispose();
    _description.dispose();
    _otherLabel.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.resolveCurrentLocation();
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      setState(() {
        _draft = result.data;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = false;
      _error = result.failure?.message ?? 'Could not detect location';
      _draft = const DeliveryLocationEntity(
        latitude: 17.6868,
        longitude: 83.2185,
        address: '',
        addressType: 'Home',
      );
    });
  }

  void _applyDraft(DeliveryLocationEntity draft) {
    setState(() {
      _draft = draft;
      _error = null;
    });
  }

  Future<void> _openSearch() async {
    final place = await Navigator.of(context).push<DeliveryLocationEntity>(
      MaterialPageRoute(builder: (_) => const PlaceSearchPage()),
    );
    if (place != null && mounted) {
      _applyDraft(place);
    }
  }

  Future<void> _openMapPicker() async {
    final draft = _draft;
    if (draft == null) return;
    final confirmed = await Navigator.of(context).push<DeliveryLocationEntity>(
      MaterialPageRoute(
        builder: (_) => LocationMapPickerPage(
          initialLatitude: draft.latitude,
          initialLongitude: draft.longitude,
          initialAddress: draft.address,
          initialCity: draft.city,
        ),
      ),
    );
    if (confirmed != null && mounted) {
      _applyDraft(confirmed);
    }
  }

  Future<void> _openGpsSettings() async {
    await Geolocator.openLocationSettings();
    await _bootstrap();
  }

  Future<void> _saveAndContinue() async {
    final draft = _draft;
    if (draft == null || draft.address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery location')),
      );
      return;
    }
    if (_landmark.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landmark is required (min 2 characters)')),
      );
      return;
    }

    setState(() => _saving = true);
    final typeText = _addressType == 'Other' ? _otherLabel.text.trim() : null;
    final result = await _repo.persistDeliveryLocation(
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.address,
      city: draft.city ?? '',
      doorNo: _doorNo.text.trim(),
      landmark: _landmark.text.trim(),
      addressDescription: _description.text.trim(),
      addressType: _addressType,
      addressTypeText: typeText,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure?.message ?? 'Could not save')),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;

    return Scaffold(
      backgroundColor: AppColors.brand,
      appBar: AppBar(
        title: const Text('Delivery location'),
        backgroundColor: AppColors.brand,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          BrandHeader(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error ??
                    'Move the map pin or search to set where we should deliver.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OutlinedButton(
                                onPressed: _openGpsSettings,
                                child: const Text('Turn on GPS'),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _openSearch,
                                  icon: const Icon(Icons.search),
                                  label: const Text('Search'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _openMapPicker,
                                  icon: const Icon(Icons.map_outlined),
                                  label: const Text('On map'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _bootstrap,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Use current location'),
                          ),
                          const SizedBox(height: 16),
                          if (draft != null && draft.address.isNotEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      draft.addressType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      draft.address,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Address type',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ['Home', 'Work', 'Other'].map((type) {
                              return ChoiceChip(
                                label: Text(type),
                                selected: _addressType == type,
                                onSelected: (_) =>
                                    setState(() => _addressType = type),
                              );
                            }).toList(),
                          ),
                          if (_addressType == 'Other') ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _otherLabel,
                              decoration: const InputDecoration(
                                labelText: 'Label (e.g. Friend\'s place)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          TextField(
                            controller: _doorNo,
                            decoration: const InputDecoration(
                              labelText: 'Flat / House no. (optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _landmark,
                            decoration: const InputDecoration(
                              labelText: 'Landmark *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _description,
                            decoration: const InputDecoration(
                              labelText: 'Directions (optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _saveAndContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brand,
                                foregroundColor: Colors.white,
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save & continue',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
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
