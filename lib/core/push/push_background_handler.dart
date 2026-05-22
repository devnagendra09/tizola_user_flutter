import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase/firebase_bootstrap.dart';
import 'push_local_notifications.dart';
import 'push_message_parser.dart';
import 'push_order_refresh_bus.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseBootstrap.ensureInitialized();
  final payload = parsePushMessage(message);
  if (payload.orderId.isNotEmpty) {
    PushOrderRefreshBus.instance.notify(payload.orderId);
  }
  await ensurePushNotificationChannel();
  await showPushLocalNotification(payload);
}
