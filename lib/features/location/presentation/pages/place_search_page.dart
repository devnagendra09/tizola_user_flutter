import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/repositories/location_repository.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final _searchController = TextEditingController();
  final _repository = sl<LocationRepository>();
  List<DeliveryLocationEntity> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final result = await _repository.searchPlaces(query);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = result.data ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search location'),
      ),
      body: Column(
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
              onChanged: _search,
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.length < 3
                          ? 'Type at least 3 characters'
                          : 'No places found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final place = _results[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.place,
                          color: AppColors.brand,
                        ),
                        title: Text(place.address),
                        subtitle: Text(
                          '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => Navigator.of(context).pop(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
