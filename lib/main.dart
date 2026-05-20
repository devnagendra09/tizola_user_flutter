import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/data/app_local_data_source.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await sl<AppLocalDataSource>().ensureDeviceId();
  await sl<AuthRepository>().initDefaults();
  await sl<DeepLinkService>().initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.brand,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TizolaApp());
}

class TizolaApp extends StatefulWidget {
  const TizolaApp({super.key});

  @override
  State<TizolaApp> createState() => _TizolaAppState();
}

class _TizolaAppState extends State<TizolaApp> {
  @override
  void dispose() {
    sl<DeepLinkService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
