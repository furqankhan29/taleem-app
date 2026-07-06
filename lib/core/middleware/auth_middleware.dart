import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/services/auth_service.dart';
import 'package:taleem/data/models/user_model.dart';

class AuthMiddleware extends GetMiddleware {
  final UserRole requiredRole;

  AuthMiddleware({required this.requiredRole});

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    if (!authService.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!authService.sessionValid.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final role = authService.currentRole.value;
    if (role == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (role != requiredRole && !_isSuperRole(role, requiredRole)) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }

    return null;
  }

  bool _isSuperRole(UserRole userRole, UserRole requiredRole) {
    const hierarchy = {
      UserRole.admin: 4,
      UserRole.teacher: 3,
      UserRole.parent: 2,
      UserRole.student: 1,
    };

    final userLevel = hierarchy[userRole] ?? 0;
    final requiredLevel = hierarchy[requiredRole] ?? 0;

    return userLevel >= requiredLevel;
  }
}
