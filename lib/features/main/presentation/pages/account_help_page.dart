import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';

class AccountHelpPage extends StatelessWidget {
  const AccountHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: MobileApiEmptyView(
          message:
              'For order or payment help, contact support from the home screen or call customer care.',
          padding: EdgeInsets.all(24),
        ),
      ),
    );
  }
}
