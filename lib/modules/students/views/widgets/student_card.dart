import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onDelete;

  const StudentCard({
    super.key,
    required this.student,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.all(12.0),
        onTap: () => Get.toNamed(
          AppRoutes.studentDetail.replaceAll(':id', student.id),
        ),
        child: Row(
          children: [
            AvatarWidget(
              imageUrl: student.photoUrl,
              name: student.name,
              size: 48.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'ID: ${student.studentId} • Grade ${student.grade ?? "10"}-${student.section ?? "A"}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            StatusChip(
              label: student.feeStatus.name,
              color: student.feeStatus == FeeStatus.cleared
                  ? AppColors.primary
                  : student.feeStatus == FeeStatus.pending
                      ? AppColors.secondary
                      : AppColors.error,
              textColor: student.feeStatus == FeeStatus.cleared
                  ? AppColors.primary
                  : student.feeStatus == FeeStatus.pending
                      ? AppColors.secondary
                      : AppColors.error,
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4.0),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20.0),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
