import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_header.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../cubit/location_onboarding_cubit.dart';
import '../cubit/location_onboarding_state.dart';

class LocationOnboardingPage extends StatelessWidget {
  const LocationOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocationOnboardingCubit>(),
      child: const _LocationOnboardingView(),
    );
  }
}

class _LocationOnboardingView extends StatefulWidget {
  const _LocationOnboardingView();

  @override
  State<_LocationOnboardingView> createState() =>
      _LocationOnboardingViewState();
}

class _LocationOnboardingViewState extends State<_LocationOnboardingView> {
  final _doorNo = TextEditingController();
  final _landmark = TextEditingController();
  final _description = TextEditingController();
  final _otherLabel = TextEditingController();

  String _addressType = 'Home';

  @override
  void dispose() {
    _doorNo.dispose();
    _landmark.dispose();
    _description.dispose();
    _otherLabel.dispose();
    super.dispose();
  }

  void _goMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationOnboardingCubit, LocationOnboardingState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == LocationOnboardingStatus.saved) {
          _goMain(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.brand,
        appBar: AppBar(
          title: const Text('Delivery location'),
          backgroundColor: AppColors.brand,
        ),
        body: Column(
          children: [
            BrandHeader(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Set your location so we can show restaurants and offers near you.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: BlocBuilder<LocationOnboardingCubit, LocationOnboardingState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.status == LocationOnboardingStatus.resolving ||
                              state.status == LocationOnboardingStatus.saving)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.brand,
                                ),
                              ),
                            ),
                          if (state.status == LocationOnboardingStatus.permissionDenied ||
                              state.status ==
                                  LocationOnboardingStatus.serviceDisabled ||
                              state.status == LocationOnboardingStatus.failure)
                            _MessageCard(
                              message: state.errorMessage ?? 'Something went wrong',
                              actions: [
                                if (state.status ==
                                    LocationOnboardingStatus.serviceDisabled)
                                  TextButton(
                                    onPressed: () => context
                                        .read<LocationOnboardingCubit>()
                                        .openDeviceLocationSettings(),
                                    child: const Text('Open location settings'),
                                  ),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<LocationOnboardingCubit>()
                                      .useCurrentLocation(),
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          if (state.status == LocationOnboardingStatus.initial)
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<LocationOnboardingCubit>()
                                  .useCurrentLocation(),
                              icon: const Icon(Icons.my_location),
                              label: const Text('Use my current location'),
                            ),
                          if (state.draft != null &&
                              state.status != LocationOnboardingStatus.resolving) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.draft!.addressLine,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'City: ${state.draft!.city}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _doorNo,
                              decoration: const InputDecoration(
                                labelText: 'Flat / door no.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _landmark,
                              decoration: const InputDecoration(
                                labelText: 'Landmark (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _description,
                              decoration: const InputDecoration(
                                labelText: 'Directions (optional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Save as',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'Home', label: Text('Home')),
                                ButtonSegment(value: 'Work', label: Text('Work')),
                                ButtonSegment(value: 'Other', label: Text('Other')),
                              ],
                              selected: {_addressType},
                              onSelectionChanged: (s) {
                                setState(() => _addressType = s.first);
                              },
                            ),
                            if (_addressType == 'Other') ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _otherLabel,
                                decoration: const InputDecoration(
                                  labelText: 'Label (e.g. Parents)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: state.status ==
                                      LocationOnboardingStatus.saving
                                  ? null
                                  : () {
                                      context
                                          .read<LocationOnboardingCubit>()
                                          .saveToServerAndLocal(
                                            doorNo: _doorNo.text.trim(),
                                            landmark: _landmark.text.trim(),
                                            addressDescription:
                                                _description.text.trim(),
                                            addressType: _addressType,
                                            addressTypeText:
                                                _addressType == 'Other'
                                                    ? _otherLabel.text.trim()
                                                    : null,
                                          );
                                    },
                              child: const Text('Continue'),
                            ),
                            TextButton(
                              onPressed: () => context
                                  .read<LocationOnboardingCubit>()
                                  .useCurrentLocation(),
                              child: const Text('Pick location again'),
                            ),
                          ],
                          if (state.errorMessage != null &&
                              state.status == LocationOnboardingStatus.ready)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.actions});

  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.brandLite,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}
