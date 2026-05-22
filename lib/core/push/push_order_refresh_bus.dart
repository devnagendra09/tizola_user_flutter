import 'dart:async';

/// Android `FirebaseTokenService.push_notification_receiver` broadcast.
class PushOrderRefreshBus {
  PushOrderRefreshBus._();

  static final PushOrderRefreshBus instance = PushOrderRefreshBus._();

  final _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void notify(String orderRefId) {
    if (orderRefId.isEmpty) return;
    _controller.add(orderRefId);
  }

  void dispose() {
    _controller.close();
  }
}
