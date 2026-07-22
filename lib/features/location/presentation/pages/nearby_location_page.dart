import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../cubit/nearby_location_cubit.dart';
import '../cubit/nearby_location_state.dart';
import 'device_location_setup_page.dart';

class NearbyLocationPage extends StatefulWidget {
  const NearbyLocationPage({super.key});

  @override
  State<NearbyLocationPage> createState() => _NearbyLocationPageState();
}

class _NearbyLocationPageState extends State<NearbyLocationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goMain(BuildContext context) {
    sl<MainCubit>().loadDeliveryLocation();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainPage(),
      ),
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
          if (state.status ==
              NearbyLocationStatus.navigateToDeviceLocationSetup) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const DeviceLocationSetupPage(),
              ),
            );
          }

          if (state.status == NearbyLocationStatus.navigateToMain) {
            _goMain(context);
          }
        },
        builder: (context, state) {
          final locating = state.status == NearbyLocationStatus.initial ||
              state.status == NearbyLocationStatus.locating;

          final locationReady =
              state.status == NearbyLocationStatus.addressReady ||
                  state.showAddressCard;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 35),
                      if (locating && !locationReady)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _animation.value),
                              child: child,
                            );
                          },
                          child: Image.asset(
                            "assets/images/onboard_location.png",
                            height: 180,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.location_searching,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if(locationReady)
                        Image.asset(
                          "assets/images/onboard_location.png",
                          height: 180,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.location_searching,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      // Icon(
                      //   locationReady ? Icons.check_circle : Icons.location_on,
                      //   size: 80,
                      //   color: AppColors.brand,
                      // ),
                      // const SizedBox(height: 24),
                      Text(
                        locationReady ? "Welcome" : "Finding Your Location",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        locationReady
                            ? "We found your nearby delivery address."
                            : "Please wait while we detect your location.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),

                      if (locationReady && state.location != null) ...[
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.brand,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.location!.addressType,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.location!.address,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _goMain(context),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
