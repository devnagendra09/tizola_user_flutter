import 'package:firebase_messaging/firebase_messaging.dart';

class PushPayload {
  const PushPayload({
    required this.title,
    required this.message,
    this.orderId = '',
    this.imageUrl = '',
  });

  final String title;
  final String message;
  final String orderId;
  final String imageUrl;
}

PushPayload parsePushMessage(RemoteMessage message) {
  final data = message.data;
  if (data.isNotEmpty) {
    return PushPayload(
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      orderId: data['order_id']?.toString() ?? '',
      imageUrl: data['image']?.toString() ?? '',
    );
  }

  final notification = message.notification;
  return PushPayload(
    title: notification?.title ?? '',
    message: notification?.body ?? '',
  );
}
