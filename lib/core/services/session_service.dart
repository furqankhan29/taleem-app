import 'dart:async';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/services/auth_service.dart';
import 'package:taleem/core/network/connectivity_service.dart';
import 'package:taleem/core/utils/logger.dart';

class SessionService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();

  final RxBool isSessionValid = true.obs;

  Timer? _validationTimer;
  static const Duration _validationInterval = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    isSessionValid.value = _authService.sessionValid.value;
  }

  Future<bool> validateSession() async {
    try {
      if (!_connectivityService.isConnected.value) {
        Logger.warning('Skipping session validation: device is offline');
        return isSessionValid.value;
      }

      final valid = await _authService.checkSession();
      isSessionValid.value = valid;

      if (!valid) {
        await autoLogout();
      }

      return valid;
    } catch (e) {
      Logger.error('Session validation failed', e);
      return false;
    }
  }

  Future<void> autoLogout() async {
    try {
      Logger.warning('Session invalid, performing auto logout');

      isSessionValid.value = false;
      _authService.sessionValid.value = false;

      await _authService.signOut();

      Get.deleteAll();

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Logger.error('Auto logout failed', e);
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void startPeriodicValidation() {
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(_validationInterval, (_) async {
      await validateSession();
    });
    Logger.info('Periodic session validation started');
  }

  void stopPeriodicValidation() {
    _validationTimer?.cancel();
    _validationTimer = null;
    Logger.info('Periodic session validation stopped');
  }

  @override
  void onClose() {
    stopPeriodicValidation();
    super.onClose();
  }
}
