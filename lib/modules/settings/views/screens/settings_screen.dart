import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/app_constants.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/modules/settings/controllers/profile_controller.dart';
import 'package:taleem/modules/settings/controllers/settings_controller.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/section_header.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Appearance'),
            const SizedBox(height: AppSpacing.xs),
            _buildAppearanceCard(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Notifications'),
            const SizedBox(height: AppSpacing.xs),
            _buildNotificationsCard(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Data & Storage'),
            const SizedBox(height: AppSpacing.xs),
            _buildDataStorageCard(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Security'),
            const SizedBox(height: AppSpacing.xs),
            _buildSecurityCard(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'About'),
            const SizedBox(height: AppSpacing.xs),
            _buildAboutCard(),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(title: 'Account'),
            const SizedBox(height: AppSpacing.xs),
            _buildAccountCard(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return GlassCard(
      child: Column(
        children: [
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode'),
                subtitle: Text(
                  controller.themeMode == ThemeMode.dark
                      ? 'Dark theme enabled'
                      : 'Light theme enabled',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                secondary: Icon(
                  controller.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: AppColors.primary,
                ),
                value: controller.themeMode == ThemeMode.dark,
                onChanged: (_) => controller.toggleTheme(),
              )),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('Language'),
            subtitle: Obx(() => Text(
                  controller.language == 'en' ? 'English' : 'العربية',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                )),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return GlassCard(
      child: Column(
        children: [
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fee Reminders'),
                subtitle: Text(
                  'Get notified about upcoming fees',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                secondary: const Icon(Icons.payments_outlined,
                    color: AppColors.primary),
                value: controller.feeReminders,
                onChanged: (v) =>
                    controller.setNotificationPrefs(feeReminders: v),
              )),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Attendance Alerts'),
                subtitle: Text(
                  'Receive attendance notifications',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                secondary: const Icon(Icons.checklist_outlined,
                    color: AppColors.primary),
                value: controller.attendanceAlerts,
                onChanged: (v) =>
                    controller.setNotificationPrefs(attendanceAlerts: v),
              )),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Academic Updates'),
                subtitle: Text(
                  'Grades, reports and announcements',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                secondary: const Icon(Icons.school_outlined,
                    color: AppColors.primary),
                value: controller.academicUpdates,
                onChanged: (v) =>
                    controller.setNotificationPrefs(academicUpdates: v),
              )),
        ],
      ),
    );
  }

  Widget _buildDataStorageCard() {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.storage_outlined, color: AppColors.primary),
            title: const Text('Cache Size'),
            trailing: Text(
              '12.5 MB',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(
              'Clear Cache',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                title: 'Clear Cache',
                message:
                    'This will clear all locally cached data. You may need to re-download some content.',
                confirmLabel: 'Clear',
                isDestructive: true,
              );
              if (confirmed) {
                await controller.clearCache();
                Get.snackbar(
                  'Cache Cleared',
                  'All cached data has been cleared.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.backup_outlined,
                color: AppColors.primary),
            title: const Text('Backup Data'),
            subtitle: Text(
              'Coming soon',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fingerprint, color: AppColors.primary),
            title: const Text('Biometric Lock'),
            subtitle: Text(
              'Coming soon',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline, color: AppColors.primary),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined,
                color: AppColors.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined,
                color: AppColors.primary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('Version'),
            trailing: Text(
              AppConstants.appVersion,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.star_outline, color: AppColors.primary),
            title: const Text('Rate the App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return GlassCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Logout',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          final confirmed = await ConfirmDialog.show(
            title: 'Logout',
            message: 'Are you sure you want to logout?',
            confirmLabel: 'Logout',
            isDestructive: true,
          );
          if (confirmed) {
            Get.find<ProfileController>().logout();
          }
        },
      ),
    );
  }

  void _showLanguagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).brightness == Brightness.dark
              ? AppColors.surfaceContainerLowDark
              : AppColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.sm),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text('English'),
                onTap: () {
                  controller.setLanguage('en');
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text('العربية'),
                onTap: () {
                  controller.setLanguage('ar');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
