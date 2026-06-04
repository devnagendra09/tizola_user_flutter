import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.showReferralField = false,
    this.errorMessage,
  });

  final RegisterStatus status;
  final bool showReferralField;
  final String? errorMessage;

  RegisterState copyWith({
    RegisterStatus? status,
    bool? showReferralField,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      showReferralField: showReferralField ?? this.showReferralField,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, showReferralField, errorMessage];
}
