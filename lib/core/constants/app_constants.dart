class AppConstants {
  static const String appName = 'Tizola';
  static const String apiBaseUrl = 'https://tizola.in/api/';
 // static const String apiBaseUrl = 'http://76.13.247.242/tizola/api/';
  /// Android `AppController.SOURCE` — cart/payment APIs use this for session behavior.
  static const String source = 'android_app';

  static const String prefsName = 'tizola_prefs';
  static const String keyUsername = 'user_name';
  static const String keyAccessToken = 'access_token';
  static const String keyCountryId = 'country_id';
  static const String keyCountryDialCode = 'country_dial_code';
  static const String keyCountryName = 'country_name';
  static const String keyUserName = 'customer_name';
  static const String keyUserEmail = 'email';
  static const String keyDeviceId = 'device_id';
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyAddress = 'delivery_address';
  static const String keyAddressType = 'delivery_address_type';
  static const String keyDoorNo = 'delivery_door_no';
  static const String keyLandmark = 'delivery_landmark';
  static const String keyAddressDescription = 'delivery_address_description';
  static const String keyLocationId = 'delivery_location_id';
  static const String keyAppLanguage = 'app_language';
  static const String defaultLanguageCode = 'en';
  static const String defaultCountryId = '1';
  static const String defaultDialCode = '+91';
  static const String currentLocationLabel = 'Current Location';
  static const String yourLocationLabel = 'YOUR LOCATION';

  static const int splashDelayMs = 3000;
  static const int otpResendSeconds = 15;
  static const double nearbyAddressKmThreshold = 0.5;

  static const String tagline =
      "India's Leading Local Food Delivery App";
}
