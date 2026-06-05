import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../core/navigation/location_gate_navigation.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';

/// Android `RegisterActivity` — name, email, optional referral.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(sl()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterRegister(BuildContext context) async {
    await navigateAfterAuthLocationGate(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          _navigateAfterRegister(context);
        }
      },
      builder: (context, state) {
        final loading = state.status == RegisterStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.brand.withValues(alpha: 0.6),
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          //   foregroundColor: Colors.white,
          //   centerTitle: true,
          //   title: const Text(
          //     'Registration',
          //     style: TextStyle(
          //       fontWeight: FontWeight.w600,
          //       fontSize: 18,
          //     ),
          //   ),
          // ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// ANIMATED LOGO
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(AppAssets.logo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// TITLE SECTION
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Create Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tell us who you are to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// FORM CARD
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: AppColors.brand.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// NAME FIELD
                        _buildLabel('Full Name', Icons.person_outline),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          enabled: !loading,
                          style: const TextStyle(fontSize: 16),
                          decoration: _buildInputDecoration(
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// EMAIL FIELD
                        _buildLabel('Email Address', Icons.email_outlined),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          enabled: !loading,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 16),
                          decoration: _buildInputDecoration(
                            hint: 'your@email.com',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// REFERRAL SWITCH
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            value: state.showReferralField,
                            activeColor: AppColors.brand,
                            activeTrackColor: AppColors.brand.withOpacity(0.3),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  size: 20,
                                  color: AppColors.brand,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: const Text(
                                    'Have a referral code?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onChanged: loading
                                ? null
                                : (v) {
                              context
                                  .read<RegisterCubit>()
                                  .toggleReferral(v);
                            },
                          ),
                        ),

                        if (state.showReferralField) ...[
                          const SizedBox(height: 10),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: TextField(
                              controller: _referralController,
                              enabled: !loading,
                              style: const TextStyle(fontSize: 16),
                              decoration: _buildInputDecoration(
                                hint: 'Enter referral code',
                                icon: Icons.code,
                                isReferral: true,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        /// CONTINUE BUTTON
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () => context
                                .read<RegisterCubit>()
                                .submit(
                              name: _nameController.text,
                              email: _emailController.text,
                              referralCode: _referralController.text,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand,
                              elevation: 0,
                              shadowColor: AppColors.brand.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: loading
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// FOOTER
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Secure Registration',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 30,
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Your information is safe with us',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Powered by ${AppAssets.logo}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.brand.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    bool isReferral = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: isReferral ? AppColors.brand : Colors.grey.shade500,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: AppColors.brand,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
    );
  }
}