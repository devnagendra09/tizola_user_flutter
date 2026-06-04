import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState());

  final AuthRepository _repository;

  void toggleReferral(bool value) {
    emit(state.copyWith(showReferralField: value));
  }

  Future<void> submit({
    required String name,
    required String email,
    String? referralCode,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Please enter your name',
        ),
      );
      return;
    }

    if (trimmedEmail.isEmpty) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Please enter your email address',
        ),
      );
      return;
    }

    if (!_isValidEmail(trimmedEmail)) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Please enter a valid email address',
        ),
      );
      return;
    }

    if (state.showReferralField &&
        (referralCode == null || referralCode.trim().isEmpty)) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Please enter your referral code',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading, clearError: true));

    final result = await _repository.completeRegistration(
      name: trimmedName,
      email: trimmedEmail,
      referralCode: state.showReferralField ? referralCode?.trim() : null,
    );

    if (result.isSuccess) {
      emit(state.copyWith(status: RegisterStatus.success, clearError: true));
    } else {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: result.failure?.message ?? 'Registration failed',
        ),
      );
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
  }
}
