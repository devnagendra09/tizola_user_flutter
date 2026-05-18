import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/repositories/catalog_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryState());

  final CatalogRepository _repository;

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoryStatus.loading));

    final result = await _repository.getCuisines();

    if (result.isSuccess) {
      emit(
        state.copyWith(
          status: CategoryStatus.loaded,
          cuisines: result.data ?? [],
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
