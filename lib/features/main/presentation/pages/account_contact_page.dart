import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../cubit/contact/contact_cubit.dart';

/// Android `ContactUsFragment` — `contact_us/submit_data`.
class AccountContactPage extends StatelessWidget {
  const AccountContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactCubit(sl<AuthRepository>()),
      child: const _ContactView(),
    );
  }
}

class _ContactView extends StatefulWidget {
  const _ContactView();

  @override
  State<_ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<_ContactView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          if (state.cleared) {
            _nameController.clear();
            _emailController.clear();
            _mobileController.clear();
            _messageController.clear();
          }
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == ContactStatus.loading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact support'),
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nameController,
                enabled: !loading,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                enabled: !loading,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                enabled: !loading,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                enabled: !loading,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        final deviceInfo = await _deviceInfoLine();
                        if (!context.mounted) return;
                        context.read<ContactCubit>().submit(
                              name: _nameController.text,
                              email: _emailController.text,
                              mobile: _mobileController.text,
                              message: _messageController.text,
                              deviceInfo: deviceInfo,
                            );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _deviceInfoLine() async {
    try {
      if (Platform.isAndroid) {
        final android = await DeviceInfoPlugin().androidInfo;
        return 'Model: ${android.model}, Manufacturer: ${android.manufacturer}, '
            'Brand: ${android.brand}, OS: ${android.version.release}';
      }
      if (Platform.isIOS) {
        final ios = await DeviceInfoPlugin().iosInfo;
        return 'Model: ${ios.model}, OS: ${ios.systemVersion}';
      }
    } catch (_) {}
    return 'Unknown device';
  }
}
