import 'dart:async';

import 'package:app_links/app_links.dart';

import '../navigation/app_navigator.dart';
import '../navigation/deep_link_navigation.dart';
import 'deep_link_parser.dart';
import 'deep_link_store.dart';

class DeepLinkService {
  DeepLinkService(this._store);

  final DeepLinkStore _store;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initialize() async {
    final initial = await _appLinks.getInitialLink();
    _storeFromUri(initial);

    await _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(_onIncomingLink);
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  void _onIncomingLink(Uri? uri) {
    if (!_storeFromUri(uri)) return;
    final context = appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      openPendingShareDeepLink(context);
    }
  }

  bool _storeFromUri(Uri? uri) {
    final payload = parseShareDeepLink(uri);
    if (payload == null) return false;
    _store.setPending(payload);
    return true;
  }
}
