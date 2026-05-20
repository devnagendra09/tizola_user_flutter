import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/user_entity.dart';

enum AccountStatus { initial, loading, loaded, loggingOut, loggedOut, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.user,
    this.walletBalance = '0/-',
    this.appVersion = '',
    this.errorMessage,
  });

  final AccountStatus status;
  final UserEntity? user;
  final String walletBalance;
  final String appVersion;
  final String? errorMessage;

  bool get isBusy =>
      status == AccountStatus.loading || status == AccountStatus.loggingOut;

  AccountState copyWith({
    AccountStatus? status,
    UserEntity? user,
    String? walletBalance,
    String? appVersion,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountState(
      status: status ?? this.status,
      user: user ?? this.user,
      walletBalance: walletBalance ?? this.walletBalance,
      appVersion: appVersion ?? this.appVersion,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, user, walletBalance, appVersion, errorMessage];
}
