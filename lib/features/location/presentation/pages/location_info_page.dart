import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/delivery_location_entity.dart';
import '../cubit/location_info_cubit.dart';
import '../cubit/location_info_state.dart';
import 'place_search_page.dart';

class LocationInfoPage extends StatefulWidget {
  const LocationInfoPage({super.key});

  @override
  State<LocationInfoPage> createState() => _LocationInfoPageState();
}

class _LocationInfoPageState extends State<LocationInfoPage> {
  final _doorNo = TextEditingController();
  final _landmark = TextEditingController();
  final _description = TextEditingController();
  final _otherLabel = TextEditingController();
  String? _lastDraftKey;

  @override
  void dispose() {
    _doorNo.dispose();
    _landmark.dispose();
    _description.dispose();
    _otherLabel.dispose();
    super.dispose();
  }

  void _syncFields(DeliveryLocationEntity? draft) {
    if (draft == null) return;
    final key = '${draft.id}_${draft.address}';
    if (_lastDraftKey == key) return;
    _lastDraftKey = key;
    _doorNo.text = draft.doorNo ?? '';
    _landmark.text = draft.landmark ?? '';
    _description.text = draft.addressDescription ?? '';
    _otherLabel.text = draft.addressTypeText ?? '';
  }

  Future<void> _openSearch(BuildContext context) async {
    final place = await Navigator.of(context).push<DeliveryLocationEntity>(
      MaterialPageRoute(builder: (_) => const PlaceSearchPage()),
    );
    if (place != null && context.mounted) {
      context.read<LocationInfoCubit>().applyDraft(
            place.copyWith(id: null, addressType: 'Home'),
          );
      _lastDraftKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocationInfoCubit>()..load(),
      child: BlocConsumer<LocationInfoCubit, LocationInfoState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
          _syncFields(state.draft);
        },
        builder: (context, state) {
          final loading = state.status == LocationInfoStatus.loading ||
              state.status == LocationInfoStatus.saving;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Location'),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _openSearch(context),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Search for location',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.my_location,
                          color: AppColors.brand,
                        ),
                        title: const Text(
                          'Use my current location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brand,
                          ),
                        ),
                        onTap: loading
                            ? null
                            : () {
                                context
                                    .read<LocationInfoCubit>()
                                    .useCurrentLocation();
                                _lastDraftKey = null;
                              },
                      ),
                      if (state.hasMapPreview)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(10),
                          color: AppColors.splash,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.map,
                                color: AppColors.brand,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.draft!.address,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _doorNo,
                          decoration: const InputDecoration(
                            labelText: 'Flat / door no.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _landmark,
                          decoration: const InputDecoration(
                            labelText: 'Landmark',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _description,
                          decoration: const InputDecoration(
                            labelText: 'Address description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Home',
                              label: Text('Home'),
                            ),
                            ButtonSegment(
                              value: 'Work',
                              label: Text('Work'),
                            ),
                            ButtonSegment(
                              value: 'Other',
                              label: Text('Other'),
                            ),
                          ],
                          selected: {state.addressType},
                          onSelectionChanged: (s) {
                            context
                                .read<LocationInfoCubit>()
                                .setAddressType(s.first);
                          },
                        ),
                      ),
                      if (state.showOtherLabel) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _otherLabel,
                            decoration: const InputDecoration(
                              labelText: 'Other label',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (state.showEditButton)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: loading
                                      ? null
                                      : () async {
                                          final ok = await context
                                              .read<LocationInfoCubit>()
                                              .saveAddress(
                                                doorNo: _doorNo.text.trim(),
                                                landmark: _landmark.text.trim(),
                                                addressDescription:
                                                    _description.text.trim(),
                                                addressType: state.addressType,
                                                addressTypeText:
                                                    state.addressType == 'Other'
                                                        ? _otherLabel.text.trim()
                                                        : null,
                                              );
                                          if (ok && context.mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.brand,
                                  ),
                                  child: const Text('Edit'),
                                ),
                              ),
                            if (state.showEditButton) const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () async {
                                        context
                                            .read<LocationInfoCubit>()
                                            .prepareNewAddress();
                                        final ok = await context
                                            .read<LocationInfoCubit>()
                                            .saveAddress(
                                              doorNo: _doorNo.text.trim(),
                                              landmark: _landmark.text.trim(),
                                              addressDescription:
                                                  _description.text.trim(),
                                              addressType: state.addressType,
                                              addressTypeText:
                                                  state.addressType == 'Other'
                                                      ? _otherLabel.text.trim()
                                                      : null,
                                              isNew: true,
                                            );
                                        if (ok && context.mounted) {
                                          Navigator.of(context).pop(true);
                                        }
                                      },
                                child: const Text('Add New'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 20, color: AppColors.splash),
                      if (state.savedAddresses.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Saved Addresses',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ...state.savedAddresses.map(
                        (addr) => _SavedAddressTile(
                          address: addr,
                          onSelect: () async {
                            final ok = await context
                                .read<LocationInfoCubit>()
                                .selectSavedAddress(addr);
                            if (ok && context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                          onEdit: () {
                            context.read<LocationInfoCubit>().applyDraft(addr);
                            _doorNo.text = addr.doorNo ?? '';
                            _landmark.text = addr.landmark ?? '';
                            _description.text = addr.addressDescription ?? '';
                            _otherLabel.text = addr.addressTypeText ?? '';
                            _lastDraftKey = null;
                          },
                          onDelete: addr.id == null
                              ? null
                              : () {
                            _confirmDeleteAddress(context, addr);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (loading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteAddress(
    BuildContext context,
    DeliveryLocationEntity addr,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete location?'),
        content: Text("Delete '${addr.addressType}' address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<LocationInfoCubit>().deleteAddress(addr.id!);
    }
  }
}

class _SavedAddressTile extends StatelessWidget {
  const _SavedAddressTile({
    required this.address,
    required this.onSelect,
    required this.onEdit,
    this.onDelete,
  });

  final DeliveryLocationEntity address;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.addressType.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
            Text(
              address.address,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
