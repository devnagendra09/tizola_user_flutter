import 'package:equatable/equatable.dart';

enum SplashStatus {
  initial,
  loading,
  navigateToNearby,
  navigateToMain,
  navigateToLogin,
  failure,
}

class SplashState extends Equatable {
  const SplashState({this.status = SplashStatus.initial, this.errorMessage});

  final SplashStatus status;
  final String? errorMessage;

  SplashState copyWith({SplashStatus? status, String? errorMessage}) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
