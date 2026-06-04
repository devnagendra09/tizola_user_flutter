import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._repository, {required this.mobile})
      : super(const OtpState(resendSeconds: AppConstants.otpResendSeconds)) {
    _startResendTimer();
  }

  final AuthRepository _repository;
  final String mobile;
  Timer? _timer;

  void _startResendTimer() {
    _timer?.cancel();
    emit(
      OtpState(
        resendSeconds: AppConstants.otpResendSeconds,
        canResend: false,
        status: state.status,
        errorMessage: state.errorMessage,
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.resendSeconds <= 1) {
        _timer?.cancel();
        emit(state.copyWith(resendSeconds: 0, canResend: true));
      } else {
        emit(state.copyWith(resendSeconds: state.resendSeconds - 1));
      }
    });
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.length != 4) return;

    emit(state.copyWith(status: OtpStatus.loading, clearError: true));

    final result = await _repository.verifyOtp(mobile: mobile, otp: otp);

    if (result.isSuccess) {
      final user = result.data!;
      final status = user.needsProfileCompletion
          ? OtpStatus.needsRegistration
          : OtpStatus.success;
      emit(state.copyWith(status: status, clearError: true));
    } else {
      final message = result.failure?.message ?? 'Invalid OTP';
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    if (!state.canResend) return;

    emit(state.copyWith(status: OtpStatus.loading, clearError: true));

    final result = await _repository.sendOtp(mobile: mobile);

    if (result.isSuccess) {
      emit(
        state.copyWith(
          status: OtpStatus.initial,
          otpSentAgain: true,
          clearError: true,
        ),
      );
      _startResendTimer();
    } else {
      final message = result.failure?.message ?? 'Failed to resend OTP';
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
