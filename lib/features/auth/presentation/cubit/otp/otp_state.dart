import 'package:equatable/equatable.dart';

enum OtpStatus { initial, loading, success, failure }

class OtpState extends Equatable {
  const OtpState({
    this.status = OtpStatus.initial,
    this.resendSeconds = 15,
    this.canResend = false,
    this.errorMessage,
    this.otpSentAgain = false,
  });

  final OtpStatus status;
  final int resendSeconds;
  final bool canResend;
  final String? errorMessage;
  final bool otpSentAgain;

  OtpState copyWith({
    OtpStatus? status,
    int? resendSeconds,
    bool? canResend,
    String? errorMessage,
    bool? otpSentAgain,
    bool clearError = false,
    bool clearOtpSentAgain = false,
  }) {
    return OtpState(
      status: status ?? this.status,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpSentAgain: clearOtpSentAgain ? false : (otpSentAgain ?? this.otpSentAgain),
    );
  }

  @override
  List<Object?> get props =>
      [status, resendSeconds, canResend, errorMessage, otpSentAgain];
}
