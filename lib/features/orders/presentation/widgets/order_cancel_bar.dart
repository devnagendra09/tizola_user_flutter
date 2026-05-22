import 'dart:async';

import 'package:flutter/material.dart';

/// Android `btnCancel` + `orderCancelCountDown` on order summary / tracker.
class OrderCancelBar extends StatefulWidget {
  const OrderCancelBar({
    super.key,
    required this.initialSeconds,
    required this.onCancelPressed,
  });

  final int initialSeconds;
  final VoidCallback onCancelPressed;

  @override
  State<OrderCancelBar> createState() => _OrderCancelBarState();
}

class _OrderCancelBarState extends State<OrderCancelBar> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant OrderCancelBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      _secondsLeft = widget.initialSeconds;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        setState(() {});
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString();
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_secondsLeft <= 0) return const SizedBox.shrink();

    return OutlinedButton(
      onPressed: widget.onCancelPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Cancel order'),
          const SizedBox(width: 8),
          Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            _timerLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showOrderCancelReasonDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _OrderCancelReasonDialog(),
  );
}

class _OrderCancelReasonDialog extends StatefulWidget {
  const _OrderCancelReasonDialog();

  @override
  State<_OrderCancelReasonDialog> createState() =>
      _OrderCancelReasonDialogState();
}

class _OrderCancelReasonDialogState extends State<_OrderCancelReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel order'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Please enter your reason here',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a reason')),
              );
              return;
            }
            Navigator.pop(context, reason);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
