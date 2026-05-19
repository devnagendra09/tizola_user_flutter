import 'package:flutter/material.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../injection_container.dart';

Future<void> openCart(BuildContext context) async {
  final session = await sl<AuthRepository>().getSession();

  if (!context.mounted) return;

  if (!session.isSuccess || !session.data!.isLoggedIn) {
    final goLogin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login required'),
        content: const Text('Please login to view your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Login'),
          ),
        ],
      ),
    );

    if (!context.mounted || goLogin != true) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
    return;
  }

  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const CartPage()),
  );
}
