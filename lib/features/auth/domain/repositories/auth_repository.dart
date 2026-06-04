import '../../../../core/utils/result.dart';
import '../../../main/domain/entities/faq_entity.dart';
import '../../../main/domain/entities/refer_info_entity.dart';
import '../entities/auth_session_entity.dart';
import '../entities/country_entity.dart';
import '../entities/pending_feedback_entity.dart';
import '../entities/session_restore_result.dart';
import '../entities/user_entity.dart';
import '../entities/version_check_result.dart';

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

  Future<Result<String>> fetchWalletBalance();

  Future<Result<ReferInfoEntity>> fetchReferInfo();

  Future<Result<String>> updateProfile({
    required String name,
    required String email,
  });

  Future<Result<List<FaqEntity>>> fetchFaqs();

  Future<Result<void>> saveAppLanguage(String languageCode);

  String get appLanguageCode;

  String get countryDialCode;

  String? get countryName;

  Future<Result<List<CountryEntity>>> fetchCountries();

  Future<Result<void>> selectCountry(CountryEntity country);

  Future<Result<void>> initDefaults();

  Future<Result<VersionCheckResult>> checkVersion();

  Future<Result<SessionRestoreResult>> restoreSession();

  Future<Result<UserEntity>> completeRegistration({
    required String name,
    required String email,
    String? referralCode,
  });

  Future<Result<void>> submitContactUs({
    required String name,
    required String email,
    required String mobile,
    required String message,
    required String deviceInfo,
  });

  Future<Result<PendingFeedbackEntity?>> fetchPendingFeedback();

  Future<Result<void>> skipOrderFeedback({required String refId});
}
