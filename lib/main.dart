import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/cache/hive_local_cache.dart';
import 'core/constants/app_constants.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/locale/app_locale_notifier.dart';
import 'core/navigation/app_navigator.dart';
import 'core/push/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/system_ui_styles.dart';
import 'core/widgets/network_status_gate.dart';
import 'core/data/app_local_data_source.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/maps/google_maps_bootstrap.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/category/presentation/cubit/category_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/main/presentation/cubit/account/account_cubit.dart';
import 'features/main/presentation/cubit/main_cubit.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'injection_container.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await sl<HiveLocalCache>().init();
  await FirebaseBootstrap.ensureInitialized();
  await GoogleMapsBootstrap.ensureInitialized();
  await sl<AppLocalDataSource>().ensureDeviceId();
  await sl<AuthRepository>().initDefaults();
  sl<AppLocaleNotifier>().syncFromStorage();
  await sl<DeepLinkService>().initialize();
  await sl<PushNotificationService>().initialize();

  SystemChrome.setSystemUIOverlayStyle(AppSystemUi.lightScreen);

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
    final localeNotifier = sl<AppLocaleNotifier>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<MainCubit>.value(value: sl<MainCubit>()),
        BlocProvider<HomeCubit>.value(value: sl<HomeCubit>()),
        BlocProvider<OrdersCubit>.value(value: sl<OrdersCubit>()),
        BlocProvider<AccountCubit>.value(value: sl<AccountCubit>()),
        BlocProvider<CartCubit>.value(value: sl<CartCubit>()),
        BlocProvider<CategoryCubit>.value(value: sl<CategoryCubit>()),
      ],
      child: ListenableBuilder(
        listenable: localeNotifier,
        builder: (context, _) {
          return SafeArea(
            top: false,
            child: MaterialApp(
              title: AppConstants.appName,
              navigatorKey: appNavigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: localeNotifier.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) => NetworkStatusGate(
                child: child ?? const SizedBox.shrink(),
              ),
              home: const SplashPage(),
            ),
          );
        },
      ),
    );
  }
}
