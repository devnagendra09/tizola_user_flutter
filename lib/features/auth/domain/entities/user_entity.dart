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

  UserEntity copyWith({
    String? phoneNumber,
    String? name,
    String? email,
    String? accessToken,
    String? referralCode,
  }) {
    return UserEntity(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  bool get needsProfileCompletion {
    final n = name?.trim() ?? '';
    final e = email?.trim() ?? '';
    return n.isEmpty && e.isEmpty;
  }

  @override
  List<Object?> get props =>
      [phoneNumber, name, email, accessToken, referralCode];
}
