import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.mobile = '',
    this.errorMessage,
  });

  final LoginStatus status;
  final String mobile;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    String? mobile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      mobile: mobile ?? this.mobile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, mobile, errorMessage];
}
