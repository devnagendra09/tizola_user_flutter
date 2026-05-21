import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/repositories/catalog_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._catalogRepository) : super(const SearchState());

  final CatalogRepository _catalogRepository;
  Timer? _debounce;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void onQueryChanged(String query) {
    emit(state.copyWith(query: query, clearError: true));
    _debounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          status: SearchStatus.initial,
          suggestions: const [],
          clearError: true,
        ),
      );
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetch(trimmed);
    });
  }

  Future<void> _fetch(String keyword) async {
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));

    final result = await _catalogRepository.searchRestaurantNames(
      keyword: keyword,
    );

    if (result.isFailure) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          suggestions: const [],
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SearchStatus.loaded,
        suggestions: result.data ?? [],
        clearError: true,
      ),
    );
  }

  void clearQuery() {
    onQueryChanged('');
  }
}
