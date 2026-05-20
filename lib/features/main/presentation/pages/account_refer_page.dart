import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../cubit/refer_cubit.dart';

class AccountReferPage extends StatelessWidget {
  const AccountReferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReferCubit(sl<AuthRepository>())..load(),
      child: const _ReferView(),
    );
  }
}

class _ReferView extends StatelessWidget {
  const _ReferView();

  Future<void> _share(BuildContext context, ReferState state) async {
    final code = state.info.referralCode;
    if (code.isEmpty) return;
    final info = await PackageInfo.fromPlatform();
    final message =
        'Download Tizola App Use this Link: https://play.google.com/store/apps/details?id=${info.packageName}\n'
        '${state.info.description}\n'
        'Use $code';
    await Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite & Earn'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ReferCubit, ReferState>(
        builder: (context, state) {
          if (state.status == ReferStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brand),
            );
          }

          final info = state.info;

          return RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () => context.read<ReferCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (info.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      info.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                _statCard(
                  title: 'Wallet balance',
                  value: info.walletDisplay,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 12),
                _statCard(
                  title: 'Total referral earnings',
                  value: info.earningsDisplay,
                  icon: Icons.trending_up,
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Referral - ${info.totalReferrals}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryBrand,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your referral code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (info.referralCode.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandLite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    info.referralCode,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brand,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: info.referralCode),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Text copied to clipboard'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  color: AppColors.brand,
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            'Referral code not available',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: info.referralCode.isEmpty
                        ? null
                        : () => _share(context, state),
                    icon: const Icon(Icons.share),
                    label: const Text(
                      'INVITE FRIENDS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.secondaryBrand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 40, color: AppColors.brand.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
