import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/repositories/auth_repository.dart';

enum ProfileEditStatus { initial, loading, success, failure }

class ProfileEditState extends Equatable {
  const ProfileEditState({
    this.status = ProfileEditStatus.initial,
    this.errorMessage,
  });

  final ProfileEditStatus status;
  final String? errorMessage;

  ProfileEditState copyWith({
    ProfileEditStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit(this._repository) : super(const ProfileEditState());

  final AuthRepository _repository;

  Future<void> submit({required String name, required String email}) async {
    emit(state.copyWith(status: ProfileEditStatus.loading, clearError: true));
    final result = await _repository.updateProfile(name: name, email: email);
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    emit(state.copyWith(status: ProfileEditStatus.success));
  }
}
