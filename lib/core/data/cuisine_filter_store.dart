/// Global cuisine filter state — mirrors Android [AppController.cuisinesFilter].
class CuisineFilterStore {
  final List<String> _cuisineIds = [];

  List<String> get cuisineIds => List.unmodifiable(_cuisineIds);

  void toggleCuisine(String id) {
    if (_cuisineIds.contains(id)) {
      _cuisineIds.remove(id);
    } else {
      _cuisineIds.add(id);
    }
  }

  void clear() => _cuisineIds.clear();
}
