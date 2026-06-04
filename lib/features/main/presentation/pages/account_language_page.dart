import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/locale/app_locale_notifier.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class AccountLanguagePage extends StatefulWidget {
  const AccountLanguagePage({super.key});

  @override
  State<AccountLanguagePage> createState() => _AccountLanguagePageState();
}

class _AccountLanguagePageState extends State<AccountLanguagePage> {
  static const _languages = [
    _LangOption('English', 'en'),
    _LangOption('Telugu', 'te'),
    _LangOption('Hindi', 'hi'),
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = sl<AuthRepository>().appLanguageCode;
  }

  Future<void> _onSelect(String code) async {
    if (code == _selected) return;
    final l10n = AppLocalizations.of(context);
    await sl<AppLocaleNotifier>().applyLanguageCode(code);
    if (!mounted) return;
    setState(() => _selected = code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.languageSaved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final selected = lang.code == _selected;
          return Card(
            elevation: selected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: selected ? AppColors.brand : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              title: Text(
                lang.label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? AppColors.brand : Colors.black87,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check_circle, color: AppColors.brand)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: () => _onSelect(lang.code),
            ),
          );
        },
      ),
    );
  }
}

class _LangOption {
  const _LangOption(this.label, this.code);
  final String label;
  final String code;
}
