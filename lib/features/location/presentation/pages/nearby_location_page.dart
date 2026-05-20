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
  State<NearbyLocationPage> createState() =>
      _NearbyLocationPageState();
}

class _NearbyLocationPageState
    extends State<NearbyLocationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  _bounceController;

  late final Animation<double>
  _bounceAnimation;

  double _pinOffset = 0;

  @override
  void initState() {
    super.initState();

    _bounceController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 18,
    ).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _bounceController.addListener(() {
      if (mounted) {
        setState(() {
          _pinOffset =
              _bounceAnimation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _goMain(BuildContext context) {
    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
        const MainPage(),
      ),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      sl<NearbyLocationCubit>()
        ..start(),

      child: BlocConsumer<
          NearbyLocationCubit,
          NearbyLocationState>(
        listenWhen: (p, c) =>
        p.status != c.status,

        listener: (context, state) {
          if (state.status ==
              NearbyLocationStatus
                  .navigateToMain) {
            _bounceController.stop();

            _goMain(context);
          }

          else if (state.status ==
              NearbyLocationStatus
                  .navigateToManualSetup) {
            _bounceController.stop();

            Navigator.of(context)
                .pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) =>
                const LocationOnboardingPage(),
              ),
            );
          }
        },

        builder: (context, state) {
          final locating =
              state.status ==
                  NearbyLocationStatus
                      .locating ||
                  state.status ==
                      NearbyLocationStatus
                          .initial;

          if (state.status ==
              NearbyLocationStatus
                  .addressReady ||
              state.showAddressCard) {
            _bounceController.stop();
          }

          final revealPin =
              state.status ==
                  NearbyLocationStatus
                      .addressReady ||
                  state.showAddressCard;

          return Scaffold(
            body: Container(

              /// BEAUTIFUL GRADIENT
              decoration:
              const BoxDecoration(
                gradient: LinearGradient(
                  begin:
                  Alignment.topCenter,
                  end:
                  Alignment.bottomCenter,
                  colors: [
                    Color(0xFF66a4eb),

                    Color(0xFFbfcdde),
                   // Color(0xFFFFB067),
                  ],
                ),
              ),

              child: SafeArea(
                child: Column(
                  children: [

                    /// TOP SPACE
                    const SizedBox(
                        height: 50),

                    /// TITLE
                    const Text(
                      'Detecting Location',
                      style: TextStyle(
                        color:
                        Colors.white,
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    /// SUBTITLE
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 30,
                      ),

                      child: Text(
                        locating
                            ? 'Please wait while we find your current delivery location'
                            : 'Your current delivery address',
                        textAlign:
                        TextAlign
                            .center,
                        style:
                        TextStyle(
                          color: Colors
                              .white
                              .withOpacity(
                              0.9),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// LOCATION PIN
                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds:
                        400,
                      ),

                      transform:
                      Matrix4
                          .translationValues(
                        0,
                        revealPin
                            ? -60 -
                            _pinOffset
                            : -_pinOffset,
                        0,
                      ),

                      child: _LocationPin(
                        pulsing:
                        locating,
                      ),
                    ),

                    const SizedBox(
                        height: 35),

                    /// ADDRESS CARD
                    AnimatedOpacity(
                      opacity: state
                          .showAddressCard
                          ? 1
                          : 0,

                      duration:
                      const Duration(
                        milliseconds:
                        500,
                      ),

                      child:
                      AnimatedSlide(
                        offset: state
                            .showAddressCard
                            ? Offset.zero
                            : const Offset(
                          0,
                          0.3,
                        ),

                        duration:
                        const Duration(
                          milliseconds:
                          500,
                        ),

                        child: state
                            .location ==
                            null
                            ? const SizedBox
                            .shrink()
                            : Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal:
                            24,
                          ),

                          child:
                          Container(
                            width: double
                                .infinity,

                            padding:
                            const EdgeInsets
                                .all(
                              22,
                            ),

                            decoration:
                            BoxDecoration(
                              color: Colors
                                  .white,

                              borderRadius:
                              BorderRadius.circular(
                                  28),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                      0.12),

                                  blurRadius:
                                  20,

                                  offset:
                                  const Offset(
                                      0,
                                      8),
                                ),
                              ],
                            ),

                            child:
                            Column(
                              children: [

                                /// ICON
                                Container(
                                  height:
                                  70,
                                  width:
                                  70,

                                  decoration:
                                  BoxDecoration(
                                    color: AppColors
                                        .brand
                                        .withOpacity(
                                        0.1),

                                    shape:
                                    BoxShape.circle,
                                  ),

                                  child:
                                  const Icon(
                                    Icons
                                        .location_on,
                                    color:
                                    AppColors.brand,
                                    size:
                                    38,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                    18),

                                /// ADDRESS TYPE
                                Text(
                                  state
                                      .location!
                                      .addressType
                                      .toUpperCase(),

                                  style:
                                  const TextStyle(
                                    fontSize:
                                    20,
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    Colors.black87,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                    10),

                                /// ADDRESS
                                Text(
                                  state
                                      .location!
                                      .address,

                                  textAlign:
                                  TextAlign.center,

                                  style:
                                  TextStyle(
                                    fontSize:
                                    15,

                                    color: Colors
                                        .grey
                                        .shade700,

                                    height:
                                    1.6,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                    22),

                                /// BUTTON
                                SizedBox(
                                  width:
                                  double.infinity,

                                  height:
                                  54,

                                  child:
                                  ElevatedButton(
                                    onPressed:
                                        () {
                                      _goMain(
                                          context);
                                    },

                                    style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor:
                                      AppColors.brand,

                                      foregroundColor:
                                      Colors.white,

                                      elevation:
                                      0,

                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            18),
                                      ),
                                    ),

                                    child:
                                    const Text(
                                      'Confirm Location',
                                      style:
                                      TextStyle(
                                        fontSize:
                                        16,

                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// LOADING
                    if (locating)
                      Column(
                        children: [

                          const SizedBox(
                              height: 10),

                          SizedBox(
                            height: 28,
                            width: 28,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              3,
                              color:
                              Colors.white,
                            ),
                          ),

                          const SizedBox(
                              height: 14),

                          Text(
                            'Fetching location...',
                            style:
                            TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                  0.9),

                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(
                        height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  const _LocationPin({
    required this.pulsing,
  });

  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [

        /// OUTER PULSE
        if (pulsing)
          Container(
            width: 180,
            height: 180,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.white
                  .withOpacity(0.10),
            ),
          ),

        /// MIDDLE PULSE
        if (pulsing)
          Container(
            width: 130,
            height: 130,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.white
                  .withOpacity(0.18),
            ),
          ),

        /// MAIN PIN
        Container(
          width: 100,
          height: 100,

          decoration: BoxDecoration(
            color: Colors.white,

            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.15),

                blurRadius: 18,

                offset:
                const Offset(0, 8),
              ),
            ],
          ),

          child: const Icon(
            Icons.location_on,
            size: 52,
            color: AppColors.brand,
          ),
        ),
      ],
    );
  }
}