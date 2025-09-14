import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Network connectivity monitoring service
class NetworkService extends GetxService {
  static const String tag = 'NetworkService';

  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Reactive variables
  final isConnected = true.obs;
  final connectionType = ConnectivityResult.none.obs;
  final isWifi = false.obs;
  final isMobile = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _connectivity = Connectivity();
    await _initializeNetworkMonitoring();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Initialize network connectivity monitoring
  Future<void> _initializeNetworkMonitoring() async {
    try {
      log('Initializing network monitoring...');

      // Check initial connectivity status
      await _checkInitialConnectivity();

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (error, stackTrace) {
          log('Network monitoring error', error: error, stackTrace: stackTrace);
        },
      );

      log('Network monitoring initialized successfully');
    } catch (e, stackTrace) {
      log(
        'Failed to initialize network monitoring',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e, stackTrace) {
      log(
        'Failed to check initial connectivity',
        error: e,
        stackTrace: stackTrace,
      );
      // Default to connected state if check fails
      _updateConnectivityState([ConnectivityResult.wifi]);
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    log('Connectivity changed: $results');
    _updateConnectivityState(results);

    // Show user feedback for connection changes
    _showConnectivityFeedback(results);
  }

  /// Update connectivity state based on results
  void _updateConnectivityState(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    isConnected.value = hasConnection;

    if (results.isNotEmpty) {
      connectionType.value = results.first;
      isWifi.value = results.contains(ConnectivityResult.wifi);
      isMobile.value = results.contains(ConnectivityResult.mobile);
    } else {
      connectionType.value = ConnectivityResult.none;
      isWifi.value = false;
      isMobile.value = false;
    }

    log(
      'Network status updated - Connected: $hasConnection, Type: ${connectionType.value}',
    );
  }

  /// Show user feedback for connectivity changes
  void _showConnectivityFeedback(List<ConnectivityResult> results) {
    if (results.any((result) => result != ConnectivityResult.none)) {
      if (!isConnected.value) {
        // Connection restored
        Get.showSnackbar(
          const GetSnackBar(
            title: 'Connection Restored',
            message: 'You are back online!',
            icon: Icon(Icons.wifi, color: Colors.white),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          ),
        );
      }
    } else {
      // Connection lost
      Get.showSnackbar(
        const GetSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection',
          icon: Icon(Icons.wifi_off, color: Colors.white),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        ),
      );
    }
  }

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e, stackTrace) {
      log(
        'Failed to check internet connection',
        error: e,
        stackTrace: stackTrace,
      );
      return isConnected.value; // Return cached value
    }
  }

  /// Get current connection type as string
  String get connectionTypeString {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Check if device is on a metered connection (mobile data)
  bool get isOnMeteredConnection => isMobile.value;

  /// Check if device can handle large downloads
  bool get canHandleLargeDownloads => isWifi.value || !isMobile.value;

  /// Wait for internet connection
  Future<void> waitForConnection({Duration? timeout}) async {
    if (isConnected.value) return;

    final completer = Completer<void>();
    StreamSubscription? subscription;
    Timer? timeoutTimer;

    subscription = isConnected.listen((connected) {
      if (connected) {
        subscription?.cancel();
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    if (timeout != null) {
      timeoutTimer = Timer(timeout, () {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException(
              'Timeout waiting for internet connection',
              timeout,
            ),
          );
        }
      });
    }

    return completer.future;
  }
}
