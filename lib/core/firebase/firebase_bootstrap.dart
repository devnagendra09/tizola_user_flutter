import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../constants/firebase_constants.dart';

class FirebaseBootstrap {
  static var _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDTWIXdReUwizouqj76EbLAeZAARAeBjQI',
          appId: '1:89742411943:android:3661b6482ad1cd598ab382',
          messagingSenderId: '89742411943',
          projectId: 'tizola-cmoon',
          databaseURL: FirebaseConstants.databaseUrl,
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
    }
  }
}
