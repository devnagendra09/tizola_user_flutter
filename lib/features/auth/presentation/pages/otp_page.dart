import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/otp_input.dart';
import '../../../../injection_container.dart';
import '../../../../core/navigation/location_gate_navigation.dart';
import 'register_page.dart';
import '../cubit/otp/otp_cubit.dart';
import '../cubit/otp/otp_state.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key, required this.mobile});

  final String mobile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OtpCubit>(param1: mobile),
      child: _OtpView(mobile: mobile),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.mobile});

  final String mobile;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> with CodeAutoFill {
  final _otpKey = GlobalKey<OtpInputState>();
  StreamSubscription<String>? _smsSub;

  @override
  void initState() {
    super.initState();
    _listenForSms();
  }

  Future<void> _listenForSms() async {
    try {
      await SmsAutoFill().listenForCode();
      _smsSub = SmsAutoFill().code.listen((code) {
        final digits = code.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 4 && mounted) {
          final otp = digits.substring(0, 4);
          _otpKey.currentState?.setCode(otp);
          context.read<OtpCubit>().verifyOtp(otp);
        }
      });
    } catch (_) {}
  }

  @override
  void codeUpdated() {
    final received = code;
    if (received == null || received.isEmpty || !mounted) return;
    final digits = received.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      final otp = digits.substring(0, 4);
      _otpKey.currentState?.setCode(otp);
      context.read<OtpCubit>().verifyOtp(otp);
    }
  }

  @override
  void dispose() {
    _smsSub?.cancel();
    SmsAutoFill().unregisterListener();
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.otpSentAgain != curr.otpSentAgain,
      listener: (context, state) {
        if (state.status == OtpStatus.needsRegistration) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
            (_) => false,
          );
        } else if (state.status == OtpStatus.success) {
          navigateAfterAuthLocationGate(context);
        }

        if (state.status == OtpStatus.failure) {
          _otpKey.currentState?.clear();
        }

        if (state.otpSentAgain) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.brand,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: const Text('OTP sent again'),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: AppColors.brand,

        body: BlocBuilder<OtpCubit, OtpState>(
          builder: (context, state) {
            final loading = state.status == OtpStatus.loading;

            return Stack(
              children: [
                /// BODY
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// BACK
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// LOGO
                        Container(
                          height: 110,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(
                              'assets/images/main_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        /// TITLE
                        const Text(
                          'OTP Verification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// SUBTITLE
                        Text(
                          'Enter the 4 digit code sent to\n+91 ${widget.mobile}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// CARD
                        Container(
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(24),

                            child: Column(
                              children: [
                                /// ICON
                                Container(
                                  height: 70,
                                  width: 70,

                                  decoration: BoxDecoration(
                                    color: AppColors.brand.withOpacity(0.1),

                                    shape: BoxShape.circle,
                                  ),

                                  child: const Icon(
                                    Icons.sms_outlined,
                                    size: 34,
                                    color: AppColors.brand,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Verification Code',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Please enter the OTP sent to your mobile number',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                /// OTP INPUT
                                OtpInput(
                                  key: _otpKey,
                                  onCompleted: (otp) {
                                    context.read<OtpCubit>().verifyOtp(otp);
                                  },
                                ),

                                /// ERROR
                                if (state.errorMessage != null) ...[
                                  const SizedBox(height: 14),

                                  Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 30),

                                /// RESEND
                                state.canResend
                                    ? GestureDetector(
                                        onTap: loading
                                            ? null
                                            : () {
                                                context
                                                    .read<OtpCubit>()
                                                    .resendOtp();
                                              },

                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 12,
                                          ),

                                          decoration: BoxDecoration(
                                            color: AppColors.brand.withOpacity(
                                              0.08,
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),

                                          child: const Text(
                                            'Resend OTP',
                                            style: TextStyle(
                                              color: AppColors.brand,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Resend OTP in ${state.resendSeconds}s',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// LOADING
                if (loading)
                  Container(
                    color: Colors.black38,

                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
