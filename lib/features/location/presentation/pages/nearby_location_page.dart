import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../../main/presentation/pages/main_page.dart';
import '../cubit/nearby_location_cubit.dart';
import '../cubit/nearby_location_state.dart';
import 'device_location_setup_page.dart';
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
          _pinOffset = _bounceAnimation.value;
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
    sl<MainCubit>().loadDeliveryLocation();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const MainPage(),
      ),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) =>
      sl<NearbyLocationCubit>()..start(),

      child: BlocConsumer<
          NearbyLocationCubit,
          NearbyLocationState>(

        listenWhen: (p, c) =>
        p.status != c.status,

        listener: (context, state) {

          if (state.status ==
              NearbyLocationStatus.navigateToMain) {

            _bounceController.stop();

            _goMain(context);
          }

          else if (state.status ==
              NearbyLocationStatus.navigateToDeviceLocationSetup) {

            _bounceController.stop();

            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const DeviceLocationSetupPage(),
              ),
            );
          }
        },

        builder: (context, state) {

          final locating =
              state.status ==
                  NearbyLocationStatus.locating ||
                  state.status ==
                      NearbyLocationStatus.initial;

          final revealAddress =
              state.status ==
                  NearbyLocationStatus.addressReady ||
                  state.showAddressCard;

          return Scaffold(
            body: Container(

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [

                    Color(0xFF0057D9),
                    Color(0xFF4A90FF),
                    Color(0xFF89B8FF),

                  ],
                ),
              ),

              child: SafeArea(
                child: SingleChildScrollView(
                  physics:
                  const BouncingScrollPhysics(),

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                      MediaQuery.of(context)
                          .size
                          .height,
                    ),

                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 22,
                      ),

                      child: Column(
                        children: [

                          const SizedBox(height: 24),

                          /// TOP ICON
                          AnimatedSwitcher(
                            duration:
                            const Duration(
                                milliseconds: 400),

                            child: revealAddress

                                ? Container(
                              key:
                              const ValueKey(
                                  'success'),

                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),

                              decoration:
                              BoxDecoration(
                                color: Colors.white
                                    .withOpacity(
                                    0.18),

                                borderRadius:
                                BorderRadius.circular(
                                    30),
                              ),

                              child: Row(
                                mainAxisSize:
                                MainAxisSize.min,

                                children: [

                                  const Icon(
                                    Icons
                                        .check_circle,
                                    color:
                                    Colors.white,
                                    size: 18,
                                  ),

                                  const SizedBox(
                                      width: 8),

                                  const Text(
                                    "Location Found",
                                    style:
                                    TextStyle(
                                      color:
                                      Colors.white,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),
                                ],
                              ),
                            )

                                : Container(
                              key:
                              const ValueKey(
                                  'loading'),

                              padding:
                              const EdgeInsets
                                  .all(16),

                              decoration:
                              BoxDecoration(
                                color: Colors
                                    .white
                                    .withOpacity(
                                    0.15),

                                shape: BoxShape
                                    .circle,
                              ),

                              child:
                              const Icon(
                                Icons
                                    .my_location_rounded,
                                color:
                                Colors.white,
                                size: 34,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          /// TITLE
                          Text(
                            revealAddress
                                ? "Location Ready"
                                : "Finding Your Location",

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// SUBTITLE
                          Text(
                            locating
                                ? 'Please wait while we detect your nearby delivery location'
                                : 'Your nearby delivery address has been detected successfully',

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.9),

                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 40),

                          /// LOCATION PIN
                          AnimatedSwitcher(
                            duration:
                            const Duration(
                              milliseconds: 400,
                            ),

                            child: revealAddress

                                ? const SizedBox
                                .shrink()

                                : AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                400,
                              ),

                              transform: Matrix4
                                  .translationValues(
                                0,
                                -_pinOffset,
                                0,
                              ),

                              child:
                              _LocationPin(
                                pulsing:
                                locating,
                              ),
                            ),
                          ),

                          if (!revealAddress)
                            const SizedBox(
                                height: 60),

                          /// ADDRESS CARD
                          AnimatedOpacity(
                            opacity:
                            revealAddress
                                ? 1
                                : 0,

                            duration:
                            const Duration(
                              milliseconds: 500,
                            ),

                            child:
                            AnimatedSlide(
                              offset:
                              revealAddress
                                  ? Offset.zero
                                  : const Offset(
                                0,
                                0.15,
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

                                  : Container(
                                width: double
                                    .infinity,

                                padding:
                                const EdgeInsets
                                    .all(
                                  18,
                                ),

                                decoration:
                                BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                      0.94),

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      30),

                                  border:
                                  Border.all(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                        0.4),
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                          0.10),

                                      blurRadius:
                                      24,

                                      offset:
                                      const Offset(
                                          0,
                                          10),
                                    ),
                                  ],
                                ),

                                child:
                                Column(
                                  children: [

                                    /// HANDLE
                                    Container(
                                      width:
                                      50,
                                      height:
                                      5,

                                      decoration:
                                      BoxDecoration(
                                        color: Colors
                                            .grey
                                            .shade300,

                                        borderRadius:
                                        BorderRadius.circular(
                                            20),
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                        20),

                                    /// ICON
                                    Container(
                                      height:
                                      64,
                                      width:
                                      64,

                                      decoration:
                                      BoxDecoration(
                                        gradient:
                                        LinearGradient(
                                          colors: [
                                            AppColors
                                                .brand,

                                            AppColors
                                                .brand
                                                .withOpacity(
                                                0.8),
                                          ],
                                        ),

                                        shape:
                                        BoxShape
                                            .circle,
                                      ),

                                      child:
                                      const Icon(
                                        Icons
                                            .location_on,
                                        color:
                                        Colors.white,
                                        size:
                                        34,
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
                                        FontWeight
                                            .w800,

                                        color: Colors
                                            .black87,
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
                                      TextAlign
                                          .center,

                                      style:
                                      TextStyle(
                                        fontSize:
                                        15,

                                        color: Colors
                                            .grey
                                            .shade700,

                                        height:
                                        1.7,
                                      ),
                                    ),

                                    const SizedBox(
                                        height:
                                        18),

                                    // /// RESTAURANTS
                                    // Container(
                                    //   padding:
                                    //   const EdgeInsets.symmetric(
                                    //     horizontal:
                                    //     12,
                                    //     vertical:
                                    //     8,
                                    //   ),
                                    //
                                    //   decoration:
                                    //   BoxDecoration(
                                    //     color: AppColors
                                    //         .brandLite
                                    //         .withOpacity(
                                    //         0.12),
                                    //
                                    //     borderRadius:
                                    //     BorderRadius.circular(
                                    //         14),
                                    //   ),
                                    //
                                    //   child:
                                    //   Row(
                                    //     mainAxisSize:
                                    //     MainAxisSize.min,
                                    //
                                    //     children: [
                                    //
                                    //       const Icon(
                                    //         Icons
                                    //             .restaurant,
                                    //         size:
                                    //         18,
                                    //         color:
                                    //         AppColors.brand,
                                    //       ),
                                    //
                                    //       const SizedBox(
                                    //           width:
                                    //           6),
                                    //
                                    //       Text(
                                    //         "12 restaurants available nearby",
                                    //
                                    //         style:
                                    //         TextStyle(
                                    //           color: Colors
                                    //               .grey
                                    //               .shade800,
                                    //
                                    //           fontWeight:
                                    //           FontWeight
                                    //               .w600,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    //
                                    // const SizedBox(
                                    //     height:
                                    //     24),

                                    /// BUTTON
                                    Container(
                                      width: double
                                          .infinity,

                                      height: 56,

                                      decoration:
                                      BoxDecoration(
                                        gradient:
                                        LinearGradient(
                                          colors: [

                                            AppColors
                                                .brand,

                                            AppColors
                                                .secondaryBrand,
                                          ],
                                        ),

                                        borderRadius:
                                        BorderRadius.circular(
                                            18),
                                      ),

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
                                          Colors
                                              .transparent,

                                          shadowColor:
                                          Colors
                                              .transparent,

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

                                    const SizedBox(
                                        height:
                                        10),

                                    /// MANUAL
                                    TextButton(
                                      onPressed:
                                          () {
                                        Navigator.of(context)
                                            .pushReplacement(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const DeviceLocationSetupPage(),
                                          ),
                                        );
                                      },

                                      child:
                                      const Text(
                                        "Enter location manually",

                                        style:
                                        TextStyle(
                                          color:
                                          AppColors
                                              .brand,

                                          fontWeight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          /// LOADER
                          if (locating &&
                              !revealAddress)
                            Column(
                              children: [

                                SizedBox(
                                  height: 28,
                                  width: 28,

                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    3,

                                    color: Colors
                                        .white,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                    14),

                                Text(
                                  'Loading nearby restaurants...',

                                  style:
                                  TextStyle(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                        0.9),

                                    fontSize:
                                    14,
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
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

        if (pulsing)
          Container(
            width: 180,
            height: 180,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
                  .withOpacity(0.08),
            ),
          ),

        if (pulsing)
          Container(
            width: 130,
            height: 130,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
                  .withOpacity(0.14),
            ),
          ),

        Container(
          width: 100,
          height: 100,

          decoration: BoxDecoration(

            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(
                    0.92),
              ],
            ),

            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: AppColors.brand
                    .withOpacity(0.35),

                blurRadius: 30,

                offset:
                const Offset(0, 10),
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