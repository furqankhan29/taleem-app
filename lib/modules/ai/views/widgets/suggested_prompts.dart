import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';

class SuggestedPrompts extends StatelessWidget {
  final List<Map<String, dynamic>> prompts;
  final Function(String) onTap;

  const SuggestedPrompts({
    super.key,
    required this.prompts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Suggested',
            style: AppTypography.labelCaps.copyWith(
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          height: 90.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: prompts.length,
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              return _PromptChip(
                title: prompt['title'] as String? ?? '',
                subtitle: prompt['subtitle'] as String? ?? '',
                icon: _getIcon(prompt['icon'] as String? ?? ''),
                onTap: () => onTap(prompt['title'] as String? ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fact_check': return Icons.fact_check_outlined;
      case 'payments': return Icons.payments_outlined;
      case 'school': return Icons.school_outlined;
      case 'notifications': return Icons.notifications_outlined;
      case 'analytics': return Icons.analytics_outlined;
      case 'warning': return Icons.warning_amber_rounded;
      case 'compare_arrows': return Icons.compare_arrows_rounded;
      case 'account_balance': return Icons.account_balance_outlined;
      default: return Icons.chat_outlined;
    }
  }
}

class _PromptChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PromptChip({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceContainerLowDark : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: (isDark ? AppColors.outlineVariantDark : AppColors.outlineVariant).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.0, color: AppColors.primary),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle,
              style: AppTypography.labelCaps.copyWith(
                fontSize: 10.0,
                color: AppColors.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
