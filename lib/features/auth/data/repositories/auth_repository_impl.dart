import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../main/domain/entities/faq_entity.dart';
import '../../../main/domain/entities/refer_info_entity.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/pending_feedback_entity.dart';
import '../../domain/entities/session_restore_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/version_check_result.dart';
import '../../domain/entities/wallet_add_result.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._appLocal);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AppLocalDataSource _appLocal;

  @override
  Future<Result<VersionCheckResult>> checkVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final result = await _remote.checkVersion(
        buildNumber: info.buildNumber,
        source: AppConstants.source,
      );
      return Result.success(result);
    } on ServerFailure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<SessionRestoreResult>> restoreSession() async {
    final phone = _local.phone;
    if (phone == null || phone.isEmpty) {
      return Result.failure(const CacheFailure());
    }
    try {
      final result = await _remote.restoreSession(mobile: phone);
      await _local.saveUser(result.user);
      return Result.success(result);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<UserEntity>> completeRegistration({
    required String name,
    required String email,
    String? referralCode,
  }) async {
    final token = _local.accessToken;
    if (token == null || token.isEmpty) {
      return Result.failure(const CacheFailure());
    }
    try {
      await _remote.completeRegistration(
        accessToken: token,
        countryId: _local.countryId,
        name: name,
        email: email,
        referralCode: referralCode,
      );
      final user = UserEntity(
        phoneNumber: _local.phone,
        name: name,
        email: email,
        accessToken: token,
      );
      await _local.saveUser(user);
      return Result.success(user);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> submitContactUs({
    required String name,
    required String email,
    required String mobile,
    required String message,
    required String deviceInfo,
  }) async {
    final token = _local.accessToken;
    if (token == null || token.isEmpty) {
      return Result.failure(const CacheFailure());
    }
    try {
      await _remote.submitContactUs(
        accessToken: token,
        name: name,
        email: email,
        mobile: mobile,
        message: message,
        deviceInfo: deviceInfo,
      );
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<PendingFeedbackEntity?>> fetchPendingFeedback() async {
    final token = _local.accessToken;
    if (token == null || token.isEmpty) {
      return Result.success(null);
    }
    try {
      final pending = await _remote.fetchPendingFeedback(accessToken: token);
      return Result.success(pending);
    } on ServerFailure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.success(null);
    }
  }

  @override
  Future<Result<void>> skipOrderFeedback({required String refId}) async {
    final token = _local.accessToken;
    if (token == null || token.isEmpty) {
      return Result.failure(const CacheFailure());
    }
    try {
      await _remote.skipOrderFeedback(accessToken: token, refId: refId);
      return Result.success(null);
    } catch (_) {
      return Result.success(null);
    }
  }

  @override
  String get countryDialCode => _local.countryDialCode;

  @override
  String? get countryName => _local.countryName;

  @override
  Future<Result<List<CountryEntity>>> fetchCountries() async {
    try {
      final list = await _remote.fetchCountries();
      return Result.success(list);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> selectCountry(CountryEntity country) async {
    try {
      await _local.saveCountrySelection(
        id: country.id,
        dialCode: country.dialCode,
        name: country.name,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(const CacheFailure());
    }
  }

  @override
  Future<Result<void>> initDefaults() async {
    try {
      if (!_local.hasCountrySelection) {
        await _local.saveCountrySelection(
          id: AppConstants.defaultCountryId,
          dialCode: AppConstants.defaultDialCode,
          name: 'India',
        );
      }
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

      if (response.type?.toLowerCase() == 'details_not_found') {
        user = user.copyWith(phoneNumber: user.phoneNumber ?? mobile);
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
        return Result.success('0');
      }
      final balance = await _remote.fetchWalletBalance(accessToken: token);
      return Result.success(balance);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.success('0');
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
  Future<Result<WalletAddResult>> addWallet({required String amount}) async {
    try {
      final token = _local.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(const CacheFailure());
      }
      final result = await _remote.addWallet(
        accessToken: token,
        amount: amount,
      );
      return Result.success(result);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const ServerFailure('Failed to add money'));
    }
  }

  @override
  Future<Result<String>> updateWalletStatus({
    required String amount,
    required String refId,
    required String razorpayOrderId,
    required String paymentGatewayId,
  }) async {
    try {
      final token = _local.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(const CacheFailure());
      }
      final message = await _remote.updateWalletStatus(
        accessToken: token,
        amount: amount,
        refId: refId,
        razorpayOrderId: razorpayOrderId,
        paymentGatewayId: paymentGatewayId,
      );
      return Result.success(message);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const ServerFailure('Failed to update wallet'));
    }
  }

  @override
  Future<Result<WalletTransactionsResult>> fetchWalletTransactions({
    int page = 1,
  }) async {
    try {
      final token = _local.accessToken;
      if (token == null || token.isEmpty) {
        return Result.failure(const CacheFailure());
      }
      final result = await _remote.fetchWalletTransactions(
        accessToken: token,
        page: page,
      );
      return Result.success(result);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(
        const ServerFailure('Failed to load wallet transactions'),
      );
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
            sessionCartId: _appLocal.sessionCartId,
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
