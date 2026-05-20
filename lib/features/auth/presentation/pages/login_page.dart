import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../cubit/login/login_cubit.dart';
import '../cubit/login/login_state.dart';
import 'otp_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OtpPage(mobile: state.mobile),
            ),
          );

          context.read<LoginCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.brand,

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// LOGO
                  Image.asset(
                    'assets/images/main_logo.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),

                  const SizedBox(height: 18),

                  /// TAGLINE
                  const Text(
                    AppConstants.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LOGIN CARD
                  Card(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.2),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                          final loading = state.status == LoginStatus.loading;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              /// TITLE
                              const Text(
                                'Login or Signup',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brand,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Enter your mobile number to continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 24),

                              /// MOBILE FIELD
                              Container(
                                height: 60,

                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(16),
                                ),

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),

                                child: Row(
                                  children: [
                                    /// FLAG
                                    const Text(
                                      '🇮🇳',
                                      style: TextStyle(fontSize: 24),
                                    ),

                                    const SizedBox(width: 8),

                                    /// CODE
                                    const Text(
                                      AppConstants.defaultDialCode,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      width: 1,
                                      height: 28,
                                      color: Colors.grey.shade400,
                                    ),

                                    /// INPUT
                                    Expanded(
                                      child: TextField(
                                        controller: _mobileController,

                                        keyboardType: TextInputType.phone,

                                        enabled: !loading,

                                        maxLength: 10,

                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],

                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),

                                        decoration: const InputDecoration(
                                          counterText: '',
                                          hintText: 'Enter mobile number',
                                          border: InputBorder.none,
                                        ),

                                        onSubmitted: (_) {
                                          context.read<LoginCubit>().sendOtp(
                                            _mobileController.text,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ERROR
                              if (state.errorMessage != null) ...[
                                const SizedBox(height: 10),

                                Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              /// BUTTON
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          context.read<LoginCubit>().sendOtp(
                                            _mobileController.text,
                                          );
                                        },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brand,

                                    foregroundColor: Colors.white,

                                    elevation: 0,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),

                                  child: loading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              /// TERMS
                              Text(
                                'By continuing, you agree to our Terms & Conditions',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
