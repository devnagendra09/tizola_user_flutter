/// Google API keys — same values as native Android `google_keys.xml` / iOS `GMSApiKey`.
///
/// Maps SDK keys are also set in:
/// - `android/app/src/main/res/values/google_keys.xml` → AndroidManifest
/// - `ios/Runner/Info.plist` → `GMSApiKey` + AppDelegate
abstract final class GoogleApiKeys {
  static const String maps = 'AIzaSyDhpAvEnaO3S5K7C0YpRYA71TirGXigIZE';
  static const String places = 'AIzaSyAjInrIF-JlbP7Kon86uTyQc7yt4X_ZXe4';
  static const String directions = 'AIzaSyC_qfcn_137_LsHG0DLmSHF4MBnUy4FI7Y';
  static const String geocoder = 'AIzaSyDIzinuDupg7IenxrDd_TO-vGq1ZSyM8q0';
}
