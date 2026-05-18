import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/cuisine_entity.dart';

enum CategoryStatus { initial, loading, loaded, failure }

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.cuisines = const [],
    this.errorMessage,
  });

  final CategoryStatus status;
  final List<CuisineEntity> cuisines;
  final String? errorMessage;

  CategoryState copyWith({
    CategoryStatus? status,
    List<CuisineEntity>? cuisines,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      cuisines: cuisines ?? this.cuisines,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cuisines, errorMessage];
}
