import 'dart:async';

import 'package:flutter/material.dart';

import 'push_order_refresh_bus.dart';

/// Refreshes order detail/tracker when a matching push arrives (Android broadcast).
class PushOrderRefreshListener extends StatefulWidget {
  const PushOrderRefreshListener({
    super.key,
    required this.refId,
    required this.onRefresh,
    required this.child,
  });

  final String refId;
  final VoidCallback onRefresh;
  final Widget child;

  @override
  State<PushOrderRefreshListener> createState() =>
      _PushOrderRefreshListenerState();
}

class _PushOrderRefreshListenerState extends State<PushOrderRefreshListener> {
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = PushOrderRefreshBus.instance.stream.listen((refId) {
      if (refId == widget.refId) {
        widget.onRefresh();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
