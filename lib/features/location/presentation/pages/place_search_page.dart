import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/entities/place_prediction_entity.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_map_picker_page.dart';

/// Android `Autocomplete.IntentBuilder` (Places API, country IN).
class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final _searchController = TextEditingController();
  final _repository = sl<LocationRepository>();
  List<PlacePredictionEntity> _results = [];
  bool _loading = false;
  bool _resolvingPlace = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final result = await _repository.searchPlacePredictions(query);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = result.data ?? [];
    });
  }

  Future<void> _selectPrediction(PlacePredictionEntity prediction) async {
    setState(() => _resolvingPlace = true);
    final result = await _repository.resolvePlaceDetails(prediction.placeId);
    if (!mounted) return;
    setState(() => _resolvingPlace = false);

    if (result.isFailure || result.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failure?.message ?? 'Could not load place details',
          ),
        ),
      );
      return;
    }

    final place = result.data!;
    final confirmed = await Navigator.of(context).push<DeliveryLocationEntity>(
      MaterialPageRoute(
        builder: (_) => LocationMapPickerPage(
          initialLatitude: place.latitude,
          initialLongitude: place.longitude,
          initialAddress: place.address,
          initialCity: place.city,
        ),
      ),
    );
    if (confirmed != null && mounted) {
      Navigator.of(context).pop(confirmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search location'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for area, street, landmark...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.grey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _results = []);
                            },
                          ),
                  ),
                  onChanged: _onQueryChanged,
                  onSubmitted: _search,
                ),
              ),
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.trim().length < 2
                              ? 'Start typing to search places'
                              : 'No places found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final prediction = _results[index];
                          final title =
                              prediction.primaryText ?? prediction.description;
                          final subtitle = prediction.secondaryText;
                          return ListTile(
                            leading: const Icon(
                              Icons.place,
                              color: AppColors.brand,
                            ),
                            title: Text(title),
                            subtitle: subtitle != null && subtitle.isNotEmpty
                                ? Text(
                                    subtitle,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                            onTap: () => _selectPrediction(prediction),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_resolvingPlace)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
            ),
        ],
      ),
    );
  }
}
