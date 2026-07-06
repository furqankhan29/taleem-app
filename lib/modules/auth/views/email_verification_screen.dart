import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/modules/auth/controllers/auth_controller.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background Gradient Circles
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Brand Logo & Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.regular),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Taleem',
                        style: AppTypography.displayLargeMobile.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Verify Your Email',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16.0),
                        const Center(
                          child: Icon(
                            Icons.mail_outline_rounded,
                            size: 80.0,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          "We've sent a verification link to your email address. Please check your inbox and click the link to verify your account.",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),

                        // Check status button
                        ElevatedButton(
                          onPressed: () => authController.checkEmailVerified(),
                          child: const Text('I Have Verified My Email'),
                        ),
                        const SizedBox(height: 12.0),

                        // Resend verification email button
                        OutlinedButton(
                          onPressed: () => authController.resendVerificationEmail(),
                          child: const Text('Resend Verification Email'),
                        ),
                        const SizedBox(height: 16.0),

                        // Back to login link
                        TextButton(
                          onPressed: () => authController.signOut(),
                          child: Text(
                            'Back to Login',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
