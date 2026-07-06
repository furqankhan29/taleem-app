import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';

class Helpers {
  Helpers._();

  static const _uuid = Uuid();

  static String generateUniqueId() => _uuid.v4();

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static void showSnackbar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: isError ? AppColors.onError : AppColors.onPrimary,
        ),
      ),
      messageText: Text(
        message,
        style: AppTypography.bodySmall.copyWith(
          color: isError ? AppColors.onError.withValues(alpha: 0.9) : AppColors.onPrimary.withValues(alpha: 0.9),
        ),
      ),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: AppRadius.regular,
      margin: const EdgeInsets.all(16.0),
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: (isError ? AppColors.error : AppColors.primary).withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  static void showLoadingDialog([String message = 'Loading...']) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: const Color(0xCCFFFFFF), width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16.0),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackbar(
      title: 'Copied',
      message: '$fieldName copied to clipboard',
    );
  }
}
