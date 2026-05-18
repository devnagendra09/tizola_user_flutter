import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.phoneNumber,
    super.name,
    super.email,
    super.accessToken,
    super.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['mobile'] as String?,
      name: json['customer_name'] as String?,
      email: json['email'] as String?,
      accessToken: json['access_token'] as String?,
      referralCode: json['referral_code'] as String?,
    );
  }

  UserEntity toEntity() => UserEntity(
        phoneNumber: phoneNumber,
        name: name,
        email: email,
        accessToken: accessToken,
        referralCode: referralCode,
      );
}
