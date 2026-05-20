import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<bool> isLoggedIn();
  String? get phone;
  String? get accessToken;
  String? get customerName;
  String? get email;
  String get countryId;
  String get appLanguageCode;

  Future<void> setCountryId(String id);
  Future<void> setAppLanguage(String code);
  Future<void> saveSession({
    required String phone,
    required String accessToken,
    String? name,
    String? email,
  });
  Future<void> saveUser(UserEntity user);
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? get phone => _prefs.getString(AppConstants.keyUsername);

  @override
  String? get accessToken => _prefs.getString(AppConstants.keyAccessToken);

  @override
  String? get customerName => _prefs.getString(AppConstants.keyUserName);

  @override
  String? get email => _prefs.getString(AppConstants.keyUserEmail);

  @override
  String get countryId =>
      _prefs.getString(AppConstants.keyCountryId) ??
      AppConstants.defaultCountryId;

  @override
  String get appLanguageCode =>
      _prefs.getString(AppConstants.keyAppLanguage) ??
      AppConstants.defaultLanguageCode;

  @override
  Future<void> setAppLanguage(String code) async {
    await _prefs.setString(AppConstants.keyAppLanguage, code);
  }

  @override
  Future<bool> isLoggedIn() async {
    final phone = _prefs.getString(AppConstants.keyUsername);
    final token = _prefs.getString(AppConstants.keyAccessToken);
    return phone != null &&
        phone.isNotEmpty &&
        token != null &&
        token.isNotEmpty;
  }

  @override
  Future<void> setCountryId(String id) async {
    await _prefs.setString(AppConstants.keyCountryId, id);
  }

  @override
  Future<void> saveSession({
    required String phone,
    required String accessToken,
    String? name,
    String? email,
  }) async {
    await _prefs.setString(AppConstants.keyUsername, phone);
    await _prefs.setString(AppConstants.keyAccessToken, accessToken);
    if (name != null) {
      await _prefs.setString(AppConstants.keyUserName, name);
    }
    if (email != null) {
      await _prefs.setString(AppConstants.keyUserEmail, email);
    }
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    if (user.phoneNumber == null || user.accessToken == null) return;
    await saveSession(
      phone: user.phoneNumber!,
      accessToken: user.accessToken!,
      name: user.name,
      email: user.email,
    );
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(AppConstants.keyUsername);
    await _prefs.remove(AppConstants.keyAccessToken);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserEmail);
  }
}
