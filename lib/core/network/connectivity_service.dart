import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:taleem/core/utils/logger.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      Logger.error('Failed to check connectivity', e);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If any interface is active, we assume we are connected
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    isConnected.value = hasConnection;
    
    if (!hasConnection) {
      Logger.warning('Device is offline');
      _showOfflineSnackbar();
    } else {
      Logger.success('Device is online');
    }
  }

  void _showOfflineSnackbar() {
    Get.rawSnackbar(
      title: 'Offline Mode',
      message: 'You are currently offline. Changes will be saved locally and synced when you reconnect.',
      isDismissible: true,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
