import '../../../../core/utils/result.dart';
import '../entities/auth_session_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<void>> sendOtp({required String mobile});

  Future<Result<UserEntity>> verifyOtp({
    required String mobile,
    required String otp,
  });

  Future<Result<AuthSessionEntity>> getSession();

  Future<Result<void>> saveUser(UserEntity user);

  Future<Result<void>> saveSession({
    required String phone,
    required String accessToken,
    String? name,
    String? email,
  });

  Future<Result<void>> logout();

  Future<Result<void>> initDefaults();
}
