import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';

class ExportButtonGroup extends StatelessWidget {
  final RxBool exporting;
  final VoidCallback? onPdfExport;
  final VoidCallback? onExcelExport;
  final VoidCallback? onCsvExport;
  final VoidCallback? onShare;

  const ExportButtonGroup({
    super.key,
    required this.exporting,
    this.onPdfExport,
    this.onExcelExport,
    this.onCsvExport,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (exporting.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Row(
        children: [
          _ExportButton(
            icon: Icons.picture_as_pdf,
            label: 'PDF',
            color: Colors.red,
            onPressed: onPdfExport,
          ),
          const SizedBox(width: 8),
          _ExportButton(
            icon: Icons.table_chart,
            label: 'Excel',
            color: Colors.green,
            onPressed: onExcelExport,
          ),
          const SizedBox(width: 8),
          _ExportButton(
            icon: Icons.description,
            label: 'CSV',
            color: Colors.blue,
            onPressed: onCsvExport,
          ),
          const Spacer(),
          if (onShare != null)
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      );
    });
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: AppTypography.labelCaps.copyWith(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
