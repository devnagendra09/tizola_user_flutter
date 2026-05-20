import 'deep_link_payload.dart';

/// Holds a pending share deep link until the app can navigate (Android `AppController` fields).
class DeepLinkStore {
  ShareDeepLinkPayload? _pending;

  ShareDeepLinkPayload? get pending => _pending;

  bool get hasPending => _pending != null;

  void setPending(ShareDeepLinkPayload payload) {
    _pending = payload;
  }

  /// Returns pending payload and clears it (one-shot navigation).
  ShareDeepLinkPayload? takePending() {
    final value = _pending;
    _pending = null;
    return value;
  }

  void clear() {
    _pending = null;
  }
}
