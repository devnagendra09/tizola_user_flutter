import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    this.phoneNumber,
    this.name,
    this.email,
    this.accessToken,
    this.referralCode,
  });

  final String? phoneNumber;
  final String? name;
  final String? email;
  final String? accessToken;
  final String? referralCode;

  @override
  List<Object?> get props =>
      [phoneNumber, name, email, accessToken, referralCode];
}
