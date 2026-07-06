import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/shared/widgets/glass_card.dart';

class AiPerformanceCard extends StatelessWidget {
  final String insight;

  const AiPerformanceCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 4.0),
          ),
        ),
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'AI Performance Insight',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            RichText(
              text: TextSpan(
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                  height: 1.5,
                ),
                children: _parseBoldText(insight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple parser to make 12% improvement in Physics bold as in design
  List<TextSpan> _parseBoldText(String text) {
    final list = <TextSpan>[];
    
    // Exact text matching pattern to highlight percentages or subjects
    final regex = RegExp(r'(12% improvement in Physics)');
    final matches = regex.allMatches(text);
    
    if (matches.isEmpty) {
      list.add(TextSpan(text: text));
      return list;
    }

    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        list.add(TextSpan(text: text.substring(start, match.start)));
      }
      list.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      ));
      start = match.end;
    }
    
    if (start < text.length) {
      list.add(TextSpan(text: text.substring(start)));
    }
    
    return list;
  }
}
