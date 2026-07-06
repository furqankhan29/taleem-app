import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';

class KpiMetricsRow extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;

  const KpiMetricsRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _KpiCard(metric: metrics[i]),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final Map<String, dynamic> metric;

  const _KpiCard({required this.metric});

  Color _getColor(String color) {
    switch (color) {
      case 'primary': return AppColors.primary;
      case 'secondary': return AppColors.secondary;
      case 'tertiary': return AppColors.tertiary;
      case 'error': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getColor(metric['color'] as String? ?? 'primary');
    final trendUp = metric['trendUp'] as bool? ?? true;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.square_foot,
                size: 18,
                color: bgColor,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: trendUp ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trendUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      metric['trend'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: trendUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metric['value'] as String? ?? '',
            style: AppTypography.headlineMedium.copyWith(
              color: bgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric['label'] as String? ?? '',
            style: AppTypography.bodySmall.copyWith(
              color: bgColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
