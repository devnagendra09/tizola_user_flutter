import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../core/widgets/otp_input.dart';
import '../../../../injection_container.dart';
import '../../../location/presentation/pages/nearby_location_page.dart';
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

class _OtpViewState extends State<_OtpView> {
  final _otpKey = GlobalKey<OtpInputState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.otpSentAgain != curr.otpSentAgain,
      listener: (context, state) {
        if (state.status == OtpStatus.success) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => const NearbyLocationPage(),
            ),
            (_) => false,
          );
        }
        if (state.status == OtpStatus.failure) {
          _otpKey.currentState?.clear();
        }
        if (state.otpSentAgain) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent again')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<OtpCubit, OtpState>(
          builder: (context, state) {
            final loading = state.status == OtpStatus.loading;
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      BrandHeader(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OTP sent to +91 ${widget.mobile}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text(
                                    'OTP has been sent to your mobile number. Please verify.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 24),
                                  OtpInput(
                                    key: _otpKey,
                                    onCompleted: (otp) => context
                                        .read<OtpCubit>()
                                        .verifyOtp(otp),
                                  ),
                                  if (state.errorMessage != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      state.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  state.canResend
                                      ? TextButton(
                                          onPressed: loading
                                              ? null
                                              : () => context
                                                  .read<OtpCubit>()
                                                  .resendOtp(),
                                          child: const Text(
                                            'RESEND',
                                            style: TextStyle(
                                              color: AppColors.secondaryBrand,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Resend OTP in ${state.resendSeconds} s',
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brand,
                      ),
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
