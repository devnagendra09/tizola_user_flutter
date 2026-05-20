import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/refer_info_entity.dart';

enum ReferStatus { initial, loading, loaded, failure }

class ReferState extends Equatable {
  const ReferState({
    this.status = ReferStatus.initial,
    this.info = const ReferInfoEntity(),
    this.errorMessage,
  });

  final ReferStatus status;
  final ReferInfoEntity info;
  final String? errorMessage;

  ReferState copyWith({
    ReferStatus? status,
    ReferInfoEntity? info,
    String? errorMessage,
  }) {
    return ReferState(
      status: status ?? this.status,
      info: info ?? this.info,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, info, errorMessage];
}

class ReferCubit extends Cubit<ReferState> {
  ReferCubit(this._repository) : super(const ReferState());

  final AuthRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ReferStatus.loading));
    final result = await _repository.fetchReferInfo();
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: ReferStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: ReferStatus.loaded,
        info: result.data ?? const ReferInfoEntity(),
      ),
    );
  }
}
