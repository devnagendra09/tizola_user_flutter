import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../location/presentation/pages/location_info_page.dart';
import '../../../restaurant/presentation/pages/restaurant_list_page.dart';
import '../../../splash/presentation/pages/splash_page.dart';
import '../cubit/account/account_cubit.dart';
import '../cubit/account/account_state.dart';
import '../cubit/main_cubit.dart';
import '../cubit/main_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../pages/account_contact_page.dart';
import '../pages/account_faq_page.dart';
import '../pages/account_language_page.dart';
import '../pages/account_profile_page.dart';
import '../pages/account_refer_page.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountCubit>(),
      child: BlocListener<MainCubit, MainState>(
        listenWhen: (prev, curr) =>
            prev.currentIndex != curr.currentIndex && curr.currentIndex == 3,
        listener: (context, _) {
          final cubit = context.read<AccountCubit>();
          if (cubit.state.status == AccountStatus.initial) {
            cubit.loadProfile();
          }
        },
        child: const _AccountView(),
      ),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryBrand),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AccountCubit>().logout();
    }
  }

  String _detailsLine(UserEntity? user) {
    if (user == null) return '';
    final phone = user.phoneNumber ?? '';
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return '$phone , $email';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.status == AccountStatus.loggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const SplashPage()),
            (_) => false,
          );
        } else if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == AccountStatus.initial ||
            state.status == AccountStatus.loading) {
          return const _AccountLoadingView();
        }

        final user = state.user;
        final l10n = AppLocalizations.of(context);
        final displayName =
            (user?.name?.trim().isNotEmpty == true ? user!.name! : 'Guest')
                .toUpperCase();

        return ColoredBox(
          color: Colors.white,
          child: RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () => context.read<AccountCubit>().loadProfile(),
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (_detailsLine(user).isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _detailsLine(user),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (user == null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(context)
                                  .push<bool>(
                                MaterialPageRoute<bool>(
                                  builder: (_) =>
                                      AccountProfilePage(user: user),
                                ),
                              )
                                  .then((updated) {
                                if (updated == true && context.mounted) {
                                  context.read<AccountCubit>().loadProfile();
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit_outlined,
                                color: AppColors.brand,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._buildMenuItems(context, user, state),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                    child: _WalletCard(
                      balance: state.walletBalance,
                      title: l10n.walletBalance,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Material(
                      color: AppColors.secondaryBrand,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: state.isBusy
                            ? null
                            : () => _confirmLogout(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user != null ? l10n.logout : l10n.login,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (state.appVersion.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      color: AppColors.splash,
                      child: Text(
                        state.appVersion,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
              if (state.status == AccountStatus.loggingOut)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.brand),
                  ),
                ),
            ],
          ),
        ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context,
    UserEntity? user,
    AccountState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final items = <_AccountMenuEntry>[
      _AccountMenuEntry(
        title: l10n.addressBook,
        icon: Icons.location_on_outlined,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const LocationInfoPage(),
            ),
          ),
        ),
      ),
      _AccountMenuEntry(
        title: l10n.allOrders,
        icon: Icons.receipt_long_outlined,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => context.read<MainCubit>().selectTab(2),
        ),
      ),
      _AccountMenuEntry(
        title: l10n.favourites,
        icon: Icons.favorite_border,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RestaurantListPage(
                title: l10n.favourites,
                favouritesOnly: true,
              ),
            ),
          ),
        ),
      ),
      _AccountMenuEntry(
        title: l10n.language,
        icon: Icons.language,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AccountLanguagePage(),
            ),
          ),
        ),
      ),
      _AccountMenuEntry(
        title: l10n.referEarn,
        icon: Icons.card_giftcard_outlined,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AccountReferPage(),
            ),
          ),
        ),
      ),
      _AccountMenuEntry(
        title: l10n.help,
        icon: Icons.support_agent_outlined,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AccountContactPage(),
            ),
          ),
        ),
      ),
      _AccountMenuEntry(
        title: l10n.helpFaq,
        icon: Icons.help_outline,
        onTap: () => _openLoggedIn(
          context,
          user,
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AccountFaqPage(),
            ),
          ),
        ),
      ),
    ];

    return items
        .map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: _AccountMenuCard(
              title: e.title,
              icon: e.icon,
              onTap: e.onTap,
            ),
          ),
        )
        .toList();
  }

  void _openLoggedIn(
    BuildContext context,
    UserEntity? user,
    VoidCallback action,
  ) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login first!'),
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            },
          ),
        ),
      );
      return;
    }
    action();
  }
}

class _AccountMenuEntry {
  const _AccountMenuEntry({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _AccountMenuCard extends StatelessWidget {
  const _AccountMenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Icon(icon, color: AppColors.brand, size: 22),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance, required this.title});

  final String balance;
  final String title;

  @override
  Widget build(BuildContext context) {
    final amount = balance.replaceAll('/-', '').trim();

    return Card(
      elevation: 8,
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.brand.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountLoadingView extends StatelessWidget {
  const _AccountLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppShimmer(
          child: Column(
            children: [
              const ShimmerBox(width: double.infinity, height: 28, borderRadius: 6),
              const SizedBox(height: 8),
              const ShimmerBox(width: 200, height: 14, borderRadius: 4),
              const SizedBox(height: 20),
              for (var i = 0; i < 5; i++) ...[
                const ShimmerBox(
                  width: double.infinity,
                  height: 52,
                  borderRadius: 10,
                ),
                const SizedBox(height: 8),
              ],
              const ShimmerBox(width: double.infinity, height: 88, borderRadius: 10),
            ],
          ),
        ),
      ],
    );
  }
}
