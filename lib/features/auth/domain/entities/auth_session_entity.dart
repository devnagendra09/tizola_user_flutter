import 'package:equatable/equatable.dart';

import 'user_entity.dart';

class AuthSessionEntity extends Equatable {
  const AuthSessionEntity({
    required this.isLoggedIn,
    this.user,
    this.responseType,
  });

  final bool isLoggedIn;
  final UserEntity? user;
  final String? responseType;

  @override
  List<Object?> get props => [isLoggedIn, user, responseType];
}
