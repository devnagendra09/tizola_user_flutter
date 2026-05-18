import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              BrandHeader(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/main_logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        AppConstants.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: BlocBuilder<LoginCubit, LoginState>(
                        builder: (context, state) {
                          final loading = state.status == LoginStatus.loading;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Enter your mobile number',
                                style: TextStyle(
                                  color: AppColors.brand,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '🇮🇳',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      AppConstants.defaultDialCode,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _mobileController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        enabled: !loading,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          hintText: 'Mobile number',
                                          border: InputBorder.none,
                                          filled: false,
                                        ),
                                        onSubmitted: (_) => context
                                            .read<LoginCubit>()
                                            .sendOtp(_mobileController.text),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (state.errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: loading
                                      ? null
                                      : () => context
                                          .read<LoginCubit>()
                                          .sendOtp(_mobileController.text),
                                  child: loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Continue'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
