import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../cubit/nearby_location_cubit.dart';
import '../cubit/nearby_location_state.dart';
import 'location_onboarding_page.dart';

class NearbyLocationPage extends StatefulWidget {
  const NearbyLocationPage({super.key});

  @override
  State<NearbyLocationPage> createState() => _NearbyLocationPageState();
}

class _NearbyLocationPageState extends State<NearbyLocationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;
  double _pinOffset = 0;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 18).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _bounceController.addListener(() {
      if (mounted) setState(() => _pinOffset = _bounceAnimation.value);
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
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
    return BlocProvider(
      create: (_) => sl<NearbyLocationCubit>()..start(),
      child: BlocConsumer<NearbyLocationCubit, NearbyLocationState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == NearbyLocationStatus.navigateToMain) {
            _bounceController.stop();
            _goMain(context);
          } else if (state.status ==
              NearbyLocationStatus.navigateToManualSetup) {
            _bounceController.stop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const LocationOnboardingPage(),
              ),
            );
          }
        },
        builder: (context, state) {
          final locating = state.status == NearbyLocationStatus.locating ||
              state.status == NearbyLocationStatus.initial;

          if (state.status == NearbyLocationStatus.addressReady ||
              state.showAddressCard) {
            _bounceController.stop();
          }

          final revealPin = state.status == NearbyLocationStatus.addressReady ||
              state.showAddressCard;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    locating
                        ? 'Finding your location...'
                        : 'Delivering to',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  Transform.translate(
                    offset: Offset(0, revealPin ? -60 - _pinOffset : _pinOffset),
                    child: _LocationPin(
                      pulsing: locating,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: state.showAddressCard ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: AnimatedSlide(
                      offset: state.showAddressCard
                          ? Offset.zero
                          : const Offset(0, 0.2),
                      duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: state.location == null
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  Text(
                                    state.location!.addressType.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.location!.address,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (locating)
                    Center(
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  const _LocationPin({required this.pulsing});

  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (pulsing)
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand.withValues(alpha: 0.12),
              ),
            ),
          ),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.brandLite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brand, width: 3),
          ),
          child: const Icon(
            Icons.location_on,
            size: 48,
            color: AppColors.brand,
          ),
        ),
      ],
    );
  }
}
