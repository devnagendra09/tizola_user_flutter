import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_message_parser.dart';
import 'push_notification_constants.dart';

/// Android small icon — same as native `R.drawable.main_logo`.
const _androidNotificationIcon = '@drawable/main_logo';

/// Brand accent for notification icon tint (Android `colorAccent`).
const _androidNotificationColor = Color(0xFF0349A9);

final FlutterLocalNotificationsPlugin pushLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> ensurePushNotificationChannel({
  DidReceiveNotificationResponseCallback? onNotificationTap,
}) async {
  const androidInit = AndroidInitializationSettings(_androidNotificationIcon);
  const iosInit = DarwinInitializationSettings();
  await pushLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
    onDidReceiveNotificationResponse: onNotificationTap,
  );

  final androidPlugin = pushLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      PushNotificationConstants.channelId,
      PushNotificationConstants.channelName,
      description: PushNotificationConstants.channelDescription,
      importance: Importance.high,
    ),
  );
}

Future<void> showPushLocalNotification(PushPayload payload) async {
  if (payload.title.isEmpty && payload.message.isEmpty) return;

  final androidDetails = AndroidNotificationDetails(
    PushNotificationConstants.channelId,
    PushNotificationConstants.channelName,
    channelDescription: PushNotificationConstants.channelDescription,
    importance: Importance.high,
    priority: Priority.high,
    icon: _androidNotificationIcon,
    color: _androidNotificationColor,
    styleInformation: payload.message.length > 80
        ? BigTextStyleInformation(payload.message)
        : null,
  );
  const iosDetails = DarwinNotificationDetails();

  await pushLocalNotificationsPlugin.show(
    payload.orderId.isNotEmpty ? payload.orderId.hashCode : 1,
    payload.title.isNotEmpty ? payload.title : 'Tizola',
    payload.message,
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    payload: payload.orderId.isNotEmpty ? payload.orderId : null,
  );
}
