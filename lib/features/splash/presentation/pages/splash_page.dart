import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/system_ui_styles.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../location/presentation/pages/nearby_location_page.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.navigateToMain) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const MainPage()),
          );
        } else if (state.status == SplashStatus.navigateToNearby) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const NearbyLocationPage(),
            ),
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
        backgroundColor: Colors.white,
        body: Center(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/flag.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/user_icon.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.brand),
                ),
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
