import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';

/// Android `UnderMaintenanceFragment`.
class UnderMaintenancePage extends StatelessWidget {
  const UnderMaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 72,
                  color: AppColors.brand.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Under maintenance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const MobileApiEmptyView(
                  message:
                      'We are temporarily unavailable. Please try again in a few minutes.',
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
