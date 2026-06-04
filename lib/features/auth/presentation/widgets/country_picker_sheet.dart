import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Android `CountriesDialogFragment` — `countries` API.
Future<CountryEntity?> showCountryPickerSheet(BuildContext context) {
  return showModalBottomSheet<CountryEntity>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => const _CountryPickerSheet(),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  var _loading = true;
  var _error = '';
  List<CountryEntity> _countries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final result = await sl<AuthRepository>().fetchCountries();
    if (!mounted) return;
    if (result.isFailure || result.data!.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Unable to load countries';
      });
      return;
    }
    setState(() {
      _loading = false;
      _countries = result.data!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectCountry,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.brand),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(_error),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _load, child: Text(l10n.retry)),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countries.length,
                  itemBuilder: (_, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: country.flagUrl != null &&
                              country.flagUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: country.flagUrl!,
                                width: 36,
                                height: 24,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.flag_outlined),
                              ),
                            )
                          : const Icon(Icons.flag_outlined),
                      title: Text(country.name),
                      subtitle: Text(country.dialCode),
                      onTap: () => Navigator.pop(context, country),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
