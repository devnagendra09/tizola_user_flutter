import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../location/domain/repositories/location_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository, this._locationRepository)
      : super(const CategoryState());

  final CatalogRepository _repository;
  final LocationRepository _locationRepository;

  String? _loadedLocationKey;

  String? _currentLocationKey() {
    final loc = _locationRepository.savedDeliveryLocation;
    if (loc == null) return null;
    return '${loc.latitude},${loc.longitude},${loc.id ?? ''}';
  }

  bool _isFreshForCurrentLocation() {
    final key = _currentLocationKey();
    return key != null &&
        _loadedLocationKey == key &&
        state.status == CategoryStatus.loaded &&
        state.cuisines.isNotEmpty;
  }

  Future<void> loadCategoriesIfNeeded() async {
    if (_isFreshForCurrentLocation()) return;
    await loadCategories();
  }

  /// Called when delivery location changes — cuisines API is location-scoped.
  Future<void> reloadForLocationChange() async {
    _loadedLocationKey = null;
    emit(const CategoryState(status: CategoryStatus.loading));
    await loadCategories();
  }

  Future<void> loadCategories() async {
    final showLoader = state.cuisines.isEmpty;
    if (showLoader) {
      emit(state.copyWith(status: CategoryStatus.loading, clearError: true));
    }

    final result = await _repository.getCuisines();

    if (isClosed) return;

    if (result.isSuccess) {
      _loadedLocationKey = _currentLocationKey();
      emit(
        state.copyWith(
          status: CategoryStatus.loaded,
          cuisines: result.data ?? [],
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
    }
  }
}
