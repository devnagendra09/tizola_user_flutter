import 'package:flutter/material.dart';

import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/presentation/pages/device_location_setup_page.dart';
import '../../features/location/presentation/pages/nearby_location_page.dart';
import '../../injection_container.dart';

/// Post-auth location gate — Android `OTPActivity` / `RegisterActivity`.
///
/// GPS + permission → [NearbyLocationPage] (match saved address).
/// Otherwise → [DeviceLocationSetupPage] (map + save first address).
Future<void> navigateAfterAuthLocationGate(BuildContext context) async {
  final canUseGps = await sl<LocationRepository>().canResolveDevicePosition();
  if (!context.mounted) return;

  final Widget next = canUseGps
      ? const NearbyLocationPage()
      : const DeviceLocationSetupPage();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => next),
    (_) => false,
  );
}
