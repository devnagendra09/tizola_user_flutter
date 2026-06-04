import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/push/push_order_refresh_listener.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/maps/directions_service.dart';
import '../../../../core/maps/google_maps_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_order_entity.dart';
import '../../../../injection_container.dart';
import '../cubit/service_order_cubit.dart';
import '../cubit/service_order_state.dart';
import '../widgets/order_cancel_bar.dart';
import '../widgets/order_support_sheet.dart';
import '../widgets/service_order_content.dart';
import '../../../main/presentation/cubit/main_cubit.dart';

/// Android `OrderTrackerActivity` — map + Firebase `driver_point` / `user_point`.
class OrderTrackerPage extends StatelessWidget {
  const OrderTrackerPage({super.key, required this.refId});

  final String refId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServiceOrderCubit>()..load(refId),
      child: Builder(
        builder: (context) => PushOrderRefreshListener(
          refId: refId,
          onRefresh: () => context
              .read<ServiceOrderCubit>()
              .load(refId, showLoading: false),
          child: _OrderTrackerView(refId: refId),
        ),
      ),
    );
  }
}

class _OrderTrackerView extends StatefulWidget {
  const _OrderTrackerView({required this.refId});

  final String refId;

  @override
  State<_OrderTrackerView> createState() => _OrderTrackerViewState();
}

class _OrderTrackerViewState extends State<_OrderTrackerView> {
  GoogleMapController? _mapController;
  StreamSubscription<DatabaseEvent>? _driverSub;
  LatLng? _userLatLng;
  LatLng? _driverLatLng;
  LatLng? _restaurantLatLng;
  ServiceOrderEntity? _order;
  final _markers = <Marker>{};
  final _polylines = <Polyline>{};
  var _trackingStarted = false;
  Timer? _routeDebounce;
  var _routeFetchGeneration = 0;

  @override
  void dispose() {
    _routeDebounce?.cancel();
    _driverSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initUserLocation(ServiceOrderEntity order) async {
    if (order.deliveryLatitude != null && order.deliveryLongitude != null) {
      final latLng = LatLng(order.deliveryLatitude!, order.deliveryLongitude!);
      _setUserLatLng(latLng);
      _pushUserPointToFirebase(latLng.latitude, latLng.longitude);
      return;
    }

    final appLocal = sl<AppLocalDataSource>();
    final lat = double.tryParse(appLocal.latitude ?? '');
    final lng = double.tryParse(appLocal.longitude ?? '');
    if (lat != null && lng != null) {
      _setUserLatLng(LatLng(lat, lng));
      _pushUserPointToFirebase(lat, lng);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      _setUserLatLng(LatLng(position.latitude, position.longitude));
      _pushUserPointToFirebase(position.latitude, position.longitude);
    } catch (_) {
      _setUserLatLng(const LatLng(17.6868, 83.2185));
    }
  }

  void _addRestaurantMarker(ServiceOrderEntity order) {
    final lat = double.tryParse(order.restaurant.latitude ?? '');
    final lng = double.tryParse(order.restaurant.longitude ?? '');
    if (lat == null || lng == null) return;
    if (!mounted) return;
    _restaurantLatLng = LatLng(lat, lng);
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('restaurant'),
          position: _restaurantLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
    _fitCamera();
    _scheduleRouteRefresh();
  }

  void _setUserLatLng(LatLng latLng) {
    if (!mounted) return;
    setState(() {
      _userLatLng = latLng;
      _markers
        ..removeWhere((m) => m.markerId.value == 'user')
        ..add(
          Marker(
            markerId: const MarkerId('user'),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
    });
    _fitCamera();
    _scheduleRouteRefresh();
  }

  void _setDriverLatLng(LatLng latLng) {
    if (!mounted) return;
    setState(() {
      _driverLatLng = latLng;
      _markers
        ..removeWhere((m) => m.markerId.value == 'driver')
        ..add(
          Marker(
            markerId: const MarkerId('driver'),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
    });
    _fitCamera();
    _scheduleRouteRefresh();
  }

  void _scheduleRouteRefresh() {
    _routeDebounce?.cancel();
    _routeDebounce = Timer(const Duration(milliseconds: 400), _refreshRoutePolyline);
  }

  bool _shouldShowUserToRestaurantDashed() {
    final order = _order;
    if (order == null || _userLatLng == null || _restaurantLatLng == null) {
      return false;
    }
    final status = order.serviceStatus.toLowerCase();
    return status == 'pending' ||
        status == 'waiting for delivery person' ||
        status == 'waiting for pickup';
  }

  void _applyPolyline({
    required List<LatLng> points,
    bool dashed = false,
  }) {
    if (!mounted || points.length < 2) return;
    setState(() {
      _polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: AppColors.brand,
            width: 5,
            geodesic: true,
            patterns: dashed
                ? <PatternItem>[
                    PatternItem.dash(28),
                    PatternItem.gap(14),
                  ]
                : <PatternItem>[],
          ),
        );
    });
    _fitCamera();
  }

  List<LatLng> _straightLinePoints(LatLng from, LatLng to, {int segments = 16}) {
    if (segments < 2) return [from, to];
    return List<LatLng>.generate(segments + 1, (i) {
      final t = i / segments;
      return LatLng(
        from.latitude + (to.latitude - from.latitude) * t,
        from.longitude + (to.longitude - from.longitude) * t,
      );
    });
  }

  Future<void> _refreshRoutePolyline() async {
    if (!mounted) return;

    final order = _order;
    final user = _userLatLng;
    final driver = _driverLatLng;
    final restaurant = _restaurantLatLng;

    if (order != null &&
        order.shouldListenDriverLocation &&
        driver != null &&
        user != null) {
      final generation = ++_routeFetchGeneration;
      final points = await sl<DirectionsService>().fetchRoute(
        origin: driver,
        destination: user,
      );
      if (!mounted || generation != _routeFetchGeneration) return;

      if (points.isNotEmpty) {
        _applyPolyline(points: points);
        return;
      }

      _applyPolyline(
        points: _straightLinePoints(driver, user),
        dashed: true,
      );
      return;
    }

    if (_shouldShowUserToRestaurantDashed() && user != null && restaurant != null) {
      _applyPolyline(
        points: _straightLinePoints(user, restaurant),
        dashed: true,
      );
    }
  }

  void _fitCamera() {
    final controller = _mapController;
    if (controller == null) return;

    final points = <LatLng>[
      if (_userLatLng != null) _userLatLng!,
      if (_driverLatLng != null) _driverLatLng!,
      ..._polylines.expand((p) => p.points),
    ];
    if (points.isEmpty) return;
    if (points.length == 1) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
      return;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points.skip(1)) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  void _pushUserPointToFirebase(double lat, double lng) {
    try {
      final ref = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: FirebaseConstants.databaseUrl,
      ).ref('${widget.refId}/user_point');
      ref.set({
        'latitude': lat.toString(),
        'longitude': lng.toString(),
      });
    } catch (_) {}
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final reason = await showOrderCancelReasonDialog(context);
    if (reason == null || !context.mounted) return;

    final cubit = context.read<ServiceOrderCubit>();
    final error = await cubit.cancelOrder(
      refId: widget.refId,
      reason: reason,
    );
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<MainCubit>().refreshInProgressOrder();
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
      }
    });
  }

  void _listenDriverLocation() {
    _driverSub?.cancel();
    try {
      final ref = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: FirebaseConstants.databaseUrl,
      ).ref('${widget.refId}/driver_point');

      _driverSub = ref.onValue.listen((event) {
        final value = event.snapshot.value;
        if (value is! Map) return;
        final lat = double.tryParse(value['latitude']?.toString() ?? '');
        final lng = double.tryParse(value['longitude']?.toString() ?? '');
        if (lat == null || lng == null) return;
        _setDriverLatLng(LatLng(lat, lng));
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splash,
      body: BlocConsumer<ServiceOrderCubit, ServiceOrderState>(
        listener: (context, state) {
          if (state.status != ServiceOrderStatus.loaded) return;
          final order = state.order;
          if (order == null) return;

          if (!order.shouldListenDriverLocation) {
            _driverSub?.cancel();
            _driverSub = null;
          }

          if (_trackingStarted) return;
          _trackingStarted = true;
          _order = order;

          _initUserLocation(order);
          _addRestaurantMarker(order);
          if (order.shouldListenDriverLocation) {
            _listenDriverLocation();
          }
        },
        builder: (context, state) {
          if (state.status == ServiceOrderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ServiceOrderStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load order'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ServiceOrderCubit>().load(widget.refId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = state.order;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final showLiveMap =
              order.canShowTrackMap && GoogleMapsBootstrap.isReady;

          return Column(
            children: [
              if (showLiveMap)
                SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _userLatLng ??
                              LatLng(
                                order.deliveryLatitude ?? 17.6868,
                                order.deliveryLongitude ?? 83.2185,
                              ),
                          zoom: 14,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _fitCamera();
                        },
                      ),
                      SafeArea(
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_back, color: Colors.black),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 40,
                        child: FloatingActionButton.small(
                          heroTag: 'focus_map',
                          backgroundColor: Colors.white,
                          onPressed: _fitCamera,
                          child: const Icon(
                            Icons.my_location,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Material(
                  color: AppColors.brand,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Expanded(
                          child: Text(
                            'Order Tracking',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brand,
                  onRefresh: () =>
                      context.read<ServiceOrderCubit>().load(widget.refId),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ServiceOrderContent(order: order),
                    ],
                  ),
                ),
              ),
              if (order.canCancelOrder || order.customerCareNumber != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.canCancelOrder)
                        OrderCancelBar(
                          key: ValueKey('cancel-${order.refId}'),
                          initialSeconds: order.remainingSeconds!,
                          onCancelPressed: () => _cancelOrder(context),
                        ),
                      if (order.customerCareNumber != null &&
                          order.customerCareNumber!.isNotEmpty) ...[
                        if (order.canCancelOrder) const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => showOrderSupportSheet(
                            context,
                            phone: order.customerCareNumber,
                            whatsApp: order.customerCareWhatsApp,
                            orderId: order.refId,
                          ),
                          child: const Text('Support'),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
