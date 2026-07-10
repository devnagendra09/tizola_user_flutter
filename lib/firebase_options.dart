import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTWIXdReUwizouqj76EbLAeZAARAeBjQI',
    appId: '1:89742411943:android:3661b6482ad1cd598ab382',
    messagingSenderId: '89742411943',
    projectId: 'tizola-cmoon',
    databaseURL: 'https://tizola-cmoon-default-rtdb.firebaseio.com',
    storageBucket: 'tizola-cmoon.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDV7Q1RpbQLQ1GMlBa9MJEc8mzt-ZbcP5g',
    appId: '1:89742411943:ios:94566a85425f6d898ab382',
    messagingSenderId: '89742411943',
    projectId: 'tizola-cmoon',
    databaseURL: 'https://tizola-cmoon-default-rtdb.firebaseio.com',
    storageBucket: 'tizola-cmoon.firebasestorage.app',
    iosBundleId: 'com.tizola.tizolaUser',
  );
}
