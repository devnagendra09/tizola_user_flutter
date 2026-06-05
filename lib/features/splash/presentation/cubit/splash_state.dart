import 'package:equatable/equatable.dart';

enum SplashStatus {
  initial,
  loading,
  navigateToNearby,
  navigateToDeviceLocationSetup,
  navigateToMain,
  navigateToLogin,
  navigateToRegister,
  navigateToMaintenance,
  forceUpdate,
  failure,
}

class SplashState extends Equatable {
  const SplashState({
    this.status = SplashStatus.initial,
    this.errorMessage,
    this.updateMessage,
  });

  final SplashStatus status;
  final String? errorMessage;
  final String? updateMessage;

  SplashState copyWith({
    SplashStatus? status,
    String? errorMessage,
    String? updateMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      updateMessage: updateMessage ?? this.updateMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, updateMessage];
}
