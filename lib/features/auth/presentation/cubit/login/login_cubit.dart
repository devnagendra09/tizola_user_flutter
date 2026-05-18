import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/phone_validator.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  Future<void> sendOtp(String rawMobile) async {
    final mobile = PhoneValidator.normalize(rawMobile);
    if (!PhoneValidator.isValidIndianMobile(mobile)) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'This phone number is invalid',
          clearError: false,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, clearError: true));

    final result = await _repository.sendOtp(mobile: mobile);

    if (result.isSuccess) {
      emit(
        state.copyWith(
          status: LoginStatus.success,
          mobile: mobile,
          clearError: true,
        ),
      );
    } else {
      final message = result.failure?.message ?? 'Something went wrong';
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  void reset() => emit(const LoginState());
}
