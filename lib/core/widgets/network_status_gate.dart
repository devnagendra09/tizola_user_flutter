import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class NetworkStatusGate extends StatefulWidget {
  const NetworkStatusGate({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkStatusGate> createState() => _NetworkStatusGateState();
}

class _NetworkStatusGateState extends State<NetworkStatusGate> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _hasResolvedStatus = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  Future<void> _refreshStatus() async {
    final results = await _connectivity.checkConnectivity();
    if (!mounted) return;

    setState(() {
      _hasResolvedStatus = true;
      _isOffline = _isOfflineState(results);
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOffline = _isOfflineState(results);
    if (!mounted || isOffline == _isOffline) return;

    setState(() {
      _hasResolvedStatus = true;
      _isOffline = isOffline;
    });
  }

  bool _isOfflineState(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        if (_hasResolvedStatus && _isOffline)
          Positioned.fill(child: NoNetworkView(onRetry: _refreshStatus)),
      ],
    );
  }
}

class NoNetworkView extends StatelessWidget {
  const NoNetworkView({super.key, this.onRetry});

  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/no_network.svg',
                  width: 220,
                  height: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Internet Connection Found!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please turn on mobile data or Wi-Fi and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetry == null ? null : () => onRetry!.call(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
