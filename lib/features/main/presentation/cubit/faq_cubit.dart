import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/faq_entity.dart';

enum FaqStatus { initial, loading, loaded, failure }

class FaqState extends Equatable {
  const FaqState({
    this.status = FaqStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final FaqStatus status;
  final List<FaqEntity> items;
  final String? errorMessage;

  FaqState copyWith({
    FaqStatus? status,
    List<FaqEntity>? items,
    String? errorMessage,
  }) {
    return FaqState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}

class FaqCubit extends Cubit<FaqState> {
  FaqCubit(this._repository) : super(const FaqState());

  final AuthRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: FaqStatus.loading));
    final result = await _repository.fetchFaqs();
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: FaqStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: FaqStatus.loaded,
        items: result.data ?? [],
      ),
    );
  }
}
