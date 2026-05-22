import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Status bar / navigation bar styles for light vs brand (blue) headers.
abstract final class AppSystemUi {
  /// Home and other light backgrounds — dark time/battery icons (Android + iOS).
  static const SystemUiOverlayStyle lightScreen = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Home hero (image or brand gradient) — light status icons, transparent bar.
  static const SystemUiOverlayStyle homeHero = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Brand app bar — white status bar icons on blue.
  static const SystemUiOverlayStyle brandAppBar = SystemUiOverlayStyle(
    statusBarColor: AppColors.brand,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
