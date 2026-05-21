import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Android Google Maps must be initialized once before any [GoogleMap] widget.
/// See `google_maps_flutter` example `initializeMapRenderer()`.
class GoogleMapsBootstrap {
  static Completer<void>? _completer;
  static var _ready = false;

  static bool get isReady => _ready;

  static Future<void> ensureInitialized() async {
    if (!Platform.isAndroid) {
      _ready = true;
      return;
    }
    if (_completer != null) return _completer!.future;

    _completer = Completer<void>();
    WidgetsFlutterBinding.ensureInitialized();

    final platform = GoogleMapsFlutterPlatform.instance;
    if (platform is GoogleMapsFlutterAndroid) {
      try {
        await platform.initializeWithRenderer(AndroidMapRenderer.latest);
        await platform.warmup();
        _ready = true;
      } catch (e, st) {
        debugPrint('GoogleMapsBootstrap failed: $e\n$st');
      }
    }

    _completer!.complete();
  }
}
