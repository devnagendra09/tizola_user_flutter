import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/system_ui_styles.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/register_page.dart';
import '../../../location/presentation/pages/device_location_setup_page.dart';
import '../../../location/presentation/pages/nearby_location_page.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import 'under_maintenance_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..checkSession(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  Future<void> _showForceUpdateDialog(
    BuildContext context,
    String? message,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('New updates'),
        content: Text(
          message?.trim().isNotEmpty == true
              ? message!
              : 'A new version of the app is available. Please update to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.tizola',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) async {
        if (state.status == SplashStatus.forceUpdate) {
          await _showForceUpdateDialog(context, state.updateMessage);
          if (context.mounted) {
            context.read<SplashCubit>().checkSession();
          }
          return;
        }
        if (state.status == SplashStatus.navigateToMaintenance) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const UnderMaintenancePage(),
            ),
          );
        } else if (state.status == SplashStatus.navigateToMain) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const MainPage()),
          );
        } else if (state.status == SplashStatus.navigateToNearby) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const NearbyLocationPage(),
            ),
          );
        } else if (state.status ==
            SplashStatus.navigateToDeviceLocationSetup) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const DeviceLocationSetupPage(),
            ),
          );
        } else if (state.status == SplashStatus.navigateToRegister) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
          );
        } else if (state.status == SplashStatus.navigateToLogin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.lightScreen,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                //  Color(0xFF89B8FF),
                  //Color(0xFF89B8FF),
                  //Color(0xFF4A90FF),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFFFFF),

                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/images/flag_nobg.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                 // const Spacer(),
                  const SizedBox(height: 50),

                  Image.asset(
                    AppAssets.logo,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
