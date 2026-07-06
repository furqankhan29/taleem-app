import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/services/ai_service.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class AiInsightsCard extends StatefulWidget {
  const AiInsightsCard({super.key});

  @override
  State<AiInsightsCard> createState() => _AiInsightsCardState();
}

class _AiInsightsCardState extends State<AiInsightsCard> {
  final BaseAIService _aiService = Get.find<BaseAIService>();
  String _insight = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    try {
      final insight = await _aiService.getDashboardInsight();
      if (mounted) {
        setState(() {
          _insight = insight;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _insight = 'AI insights temporarily unavailable.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      color: isDark 
          ? AppColors.primaryContainerDark.withValues(alpha: 0.15) 
          : AppColors.primaryContainer.withValues(alpha: 0.1),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: Stack(
        children: [
          Positioned(
            top: -40.0,
            right: -40.0,
            child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'AI Insights',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    InkWell(
                      onTap: _loadInsight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18.0,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                _isLoading ? 'Analyzing data...' : _insight,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.whatsappReminders);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.regular),
                        ),
                      ),
                      icon: const Icon(Icons.mail_outline_rounded, size: 18.0),
                      label: const Text('Draft Reminders'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainerHighDark : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.regular),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz_rounded),
                      onPressed: () {
                        Get.toNamed(AppRoutes.aiAssistant);
                      },
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
