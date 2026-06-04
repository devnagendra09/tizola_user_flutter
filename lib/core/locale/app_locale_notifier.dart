import 'package:flutter/material.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';

/// Applies saved app language — Android `LocaleManager.setNewLocale` + restart.
class AppLocaleNotifier extends ChangeNotifier {
  AppLocaleNotifier(this._authRepository)
      : _locale = Locale(_authRepository.appLanguageCode);

  final AuthRepository _authRepository;
  Locale _locale;

  Locale get locale => _locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('te'),
    Locale('hi'),
  ];

  Future<void> applyLanguageCode(String code) async {
    final normalized = _normalize(code);
    if (normalized == _locale.languageCode) return;

    final result = await _authRepository.saveAppLanguage(normalized);
    if (result.isFailure) return;

    _locale = Locale(normalized);
    notifyListeners();
  }

  void syncFromStorage() {
    final code = _normalize(_authRepository.appLanguageCode);
    if (code != _locale.languageCode) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  String _normalize(String code) {
    if (code == 'te' || code == 'hi') return code;
    return 'en';
  }
}
