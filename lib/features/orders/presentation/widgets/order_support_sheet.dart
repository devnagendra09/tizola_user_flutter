import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

/// Android `SupportContactPopFragment` — call / WhatsApp support.
void showOrderSupportSheet(
  BuildContext context, {
  String? phone,
  String? whatsApp,
  String? orderId,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (orderId != null && orderId.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Order #$orderId',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 16),
            if (phone != null && phone.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.brand),
                title: const Text('Call customer care'),
                subtitle: Text(phone),
                onTap: () => launchUrl(Uri.parse('tel:$phone')),
              ),
            if (whatsApp != null && whatsApp.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('WhatsApp'),
                subtitle: Text(whatsApp),
                onTap: () {
                  final digits = whatsApp.replaceAll(RegExp(r'\D'), '');
                  launchUrl(Uri.parse('https://wa.me/$digits'));
                },
              ),
          ],
        ),
      ),
    ),
  );
}
