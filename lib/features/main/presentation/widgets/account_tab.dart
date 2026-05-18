import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../cubit/account/account_cubit.dart';
import '../cubit/account/account_state.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountCubit>()..loadProfile(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AccountCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state.status == AccountStatus.loggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
      },
      child: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          final user = state.user;
          final phone = user?.phoneNumber ?? '';
          final name = user?.name;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.brandLite,
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: AppColors.brand.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? 'Guest User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (phone.isNotEmpty)
                              Text(
                                '+91 $phone',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _menuTile(Icons.person_outline, 'Profile', () {}),
              _menuTile(Icons.location_on_outlined, 'Addresses', () {}),
              _menuTile(Icons.help_outline, 'Help', () {}),
              _menuTile(Icons.language, 'Language', () {}),
              const Divider(height: 24),
              _menuTile(
                Icons.logout,
                'Logout',
                () => _confirmLogout(context),
                color: AppColors.error,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.brand),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
