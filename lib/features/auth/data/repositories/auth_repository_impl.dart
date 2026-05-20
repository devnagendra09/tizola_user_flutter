import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../main/domain/entities/faq_entity.dart';
import '../../../main/domain/entities/refer_info_entity.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._appLocal);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AppLocalDataSource _appLocal;

  @override
  Future<Result<void>> initDefaults() async {
    try {
      await _local.setCountryId(AppConstants.defaultCountryId);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }

  @override
  Future<Result<void>> sendOtp({required String mobile}) async {
    try {
      final response = await _remote.sendOtp(
        mobile: mobile,
        countryId: _local.countryId,
      );
      if (response.success) {
        return Result.success(null);
      }
      return Result.failure(ServerFailure(response.message ?? 'Failed to send OTP'));
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<UserEntity>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _remote.verifyOtp(
        mobile: mobile,
        otp: otp,
        countryId: _local.countryId,
      );

      if (!response.success) {
        return Result.failure(
          ServerFailure(response.message ?? 'Invalid OTP'),
        );
      }

      UserEntity user;
      if (response.user != null) {
        user = response.user!.toEntity();
        await _local.saveUser(user);
      } else if (response.accessToken != null) {
        user = UserEntity(
          phoneNumber: response.mobile ?? mobile,
          accessToken: response.accessToken,
        );
        await _local.saveSession(
          phone: user.phoneNumber!,
          accessToken: user.accessToken!,
        );
      } else {
        user = UserEntity(phoneNumber: mobile, accessToken: '');
        await _local.saveSession(phone: mobile, accessToken: '');
      }

      return Result.success(user);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AuthSessionEntity>> getSession() async {
    try {
      final loggedIn = await _local.isLoggedIn();
      if (!loggedIn) {
        return Result.success(const AuthSessionEntity(isLoggedIn: false));
      }
      return Result.success(
        AuthSessionEntity(
          isLoggedIn: true,
          user: UserEntity(
            phoneNumber: _local.phone,
            name: _local.customerName,
            email: _local.email,
            accessToken: _local.accessToken,
          ),
        ),
      );
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }

  @override
  Future<Result<void>> saveUser(UserEntity user) async {
    try {
      await _local.saveUser(user);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }

  @override
  Future<Result<void>> saveSession({
    required String phone,
    required String accessToken,
    String? name,
    String? email,
  }) async {
    try {
      await _local.saveSession(
        phone: phone,
        accessToken: accessToken,
        name: name,
        email: email,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }

  @override
  Future<Result<String>> fetchWalletBalance() async {
    try {
      final token = _local.accessToken;
      if (token == null || token.isEmpty) {
        return Result.success('0/-');
      }
      final balance = await _remote.fetchWalletBalance(accessToken: token);
      return Result.success(balance);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.success('0/-');
    }
  }

  @override
  Future<Result<ReferInfoEntity>> fetchReferInfo() async {
    try {
      final token = _local.accessToken;
      if (token == null || token.isEmpty) {
        return Result.success(const ReferInfoEntity());
      }
      final info = await _remote.fetchReferInfo(accessToken: token);
      return Result.success(info);
    } catch (_) {
      return Result.success(const ReferInfoEntity());
    }
  }

  @override
  Future<Result<String>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final token = _local.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(const CacheFailure());
      }
      final message = await _remote.updateProfile(
        accessToken: token,
        name: name,
        email: email,
      );
      await _local.saveSession(
        phone: _local.phone ?? '',
        accessToken: token,
        name: name,
        email: email,
      );
      return Result.success(message);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<FaqEntity>>> fetchFaqs() async {
    try {
      final token = _local.accessToken;
      final list = await _remote.fetchFaqs(accessToken: token);
      return Result.success(list);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> saveAppLanguage(String languageCode) async {
    try {
      await _local.setAppLanguage(languageCode);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }

  @override
  String get appLanguageCode => _local.appLanguageCode;

  @override
  Future<Result<void>> logout() async {
    try {
      final token = _local.accessToken;
      if (token != null && token.isNotEmpty) {
        try {
          await _remote.logoutRemote(
            accessToken: token,
            sessionCartId: _appLocal.deviceId,
          );
        } on Failure catch (e) {
          return Result.failure(e);
        }
      }
      await _local.logout();
      await _appLocal.clearLocation();
      return Result.success(null);
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }
}
