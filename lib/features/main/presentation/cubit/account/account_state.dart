import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/user_entity.dart';

enum AccountStatus { initial, loaded, loggedOut, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AccountStatus status;
  final UserEntity? user;
  final String? errorMessage;

  AccountState copyWith({
    AccountStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
