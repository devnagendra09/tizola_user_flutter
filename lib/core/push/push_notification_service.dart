import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/main/presentation/cubit/main_cubit.dart';
import '../../injection_container.dart';
import '../navigation/app_navigator.dart';
import '../navigation/order_navigation.dart';
import 'push_background_handler.dart';
import 'push_local_notifications.dart';
import 'push_message_parser.dart';
import 'push_order_refresh_bus.dart';
import 'push_remote_data_source.dart';

class PushNotificationService {
  PushNotificationService(
    this._remote,
    this._authRepository,
  );

  final PushRemoteDataSource _remote;
  final AuthRepository _authRepository;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;
  String? _pendingOrderRefId;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await ensurePushNotificationChannel(
        onNotificationTap: _onLocalNotificationTap,
      );

      await _requestPermissions();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      _messaging.onTokenRefresh.listen((_) => syncTokenWithServer());

      // Don't await these indefinitely as they can hang on iOS if APNS is not configured
      _setupInitialMessageAndToken();

      _initialized = true;
    } catch (e) {
      debugPrint('PushNotificationService initialization failed: $e');
    }
  }

  Future<void> _setupInitialMessageAndToken() async {
    try {
      // Use a timeout to prevent blocking the app startup
      final initial = await _messaging.getInitialMessage().timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
      if (initial != null) {
        _storePendingFromMessage(initial);
      }

      await syncTokenWithServer();
    } catch (e) {
      debugPrint('Error fetching initial message or token: $e');
    }
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
  }

  Future<void> syncTokenWithServer() async {
    try {
      final session = await _authRepository.getSession();
      if (!session.isSuccess ||
          session.data == null ||
          !session.data!.isLoggedIn) {
        return;
      }

      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (token == null || token.isEmpty) return;

      await _remote.updatePushNotificationToken(token);
    } catch (e) {
      debugPrint('Push token sync failed: $e');
    }
  }

  Future<void> handlePendingNavigation() async {
    final refId = _pendingOrderRefId;
    if (refId == null || refId.isEmpty) return;

    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    _pendingOrderRefId = null;
    openOrderDetail(context, refId: refId);
    try {
      await sl<MainCubit>().refreshInProgressOrder();
    } catch (_) {}
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final refId = response.payload?.trim() ?? '';
    if (refId.isEmpty) return;
    _pendingOrderRefId = refId;
    handlePendingNavigation();
  }

  void _onForegroundMessage(RemoteMessage message) {
    final payload = parsePushMessage(message);
    if (payload.orderId.isNotEmpty) {
      PushOrderRefreshBus.instance.notify(payload.orderId);
      try {
        sl<MainCubit>().refreshInProgressOrder();
      } catch (_) {}
    }
    showPushLocalNotification(payload);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _storePendingFromMessage(message);
    handlePendingNavigation();
  }

  void _storePendingFromMessage(RemoteMessage message) {
    final payload = parsePushMessage(message);
    if (payload.orderId.isNotEmpty) {
      _pendingOrderRefId = payload.orderId;
      PushOrderRefreshBus.instance.notify(payload.orderId);
    }
  }
}
