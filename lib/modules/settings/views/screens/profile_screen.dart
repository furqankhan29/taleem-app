import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_spacing.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/modules/settings/controllers/profile_controller.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/confirm_dialog.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.loading.value && controller.user.value == null) {
          return _buildShimmer();
        }
        final user = controller.user.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              _buildAvatarSection(user),
              const SizedBox(height: AppSpacing.sm),
              _buildPersonalInfoCard(user),
              const SizedBox(height: AppSpacing.sm),
              _buildInstituteInfoCard(user),
              const SizedBox(height: AppSpacing.sm),
              _buildAccountCard(),
              const SizedBox(height: AppSpacing.sm),
              _buildLogoutButton(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const ShimmerLoading(width: 100, height: 100, borderRadius: 50),
          const SizedBox(height: 16),
          const ShimmerLoading(width: 200, height: 24),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 150, height: 16),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerLoading(width: double.infinity, height: 180),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerLoading(width: double.infinity, height: 120),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerLoading(width: double.infinity, height: 120),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(user) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Stack(
          children: [
            AvatarWidget(
              imageUrl: user?.photoUrl,
              name: user?.displayName ?? 'User',
              size: 100,
              borderWidth: 3,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => controller.uploadPhoto(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? 'User',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/edit-profile'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, 'Name', user?.displayName ?? '-'),
          const Divider(height: 24),
          _infoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
          const Divider(height: 24),
          _infoRow(Icons.phone_outlined, 'Phone', user?.phone ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInstituteInfoCard(user) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Institute Info',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.badge_outlined, 'Role', user?.role.name.capitalizeFirst ?? '-'),
          const Divider(height: 24),
          _infoRow(Icons.calendar_today, 'Member Since',
              user?.createdAt.toLocal().toString().split(' ')[0] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await ConfirmDialog.show(
            title: 'Logout',
            message: 'Are you sure you want to logout?',
            confirmLabel: 'Logout',
            isDestructive: true,
          );
          if (confirmed) controller.logout();
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          'Logout',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
