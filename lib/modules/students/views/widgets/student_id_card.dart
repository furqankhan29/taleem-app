import 'package:flutter/material.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_radius.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/modules/students/views/widgets/qr_code_widget.dart';
import 'package:taleem/shared/widgets/avatar_widget.dart';
import 'package:taleem/shared/widgets/glass_card.dart';
import 'package:taleem/shared/widgets/status_chip.dart';

class StudentIdCard extends StatelessWidget {
  final StudentModel student;

  const StudentIdCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Stack(
        children: [
          // Background circle accent
          Positioned(
            top: -50.0,
            right: -50.0,
            child: Container(
              width: 140.0,
              height: 140.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo + Status
                    Row(
                      children: [
                        AvatarWidget(
                          imageUrl: student.photoUrl,
                          name: student.name,
                          size: 72.0,
                          borderWidth: 2.0,
                          borderColor: AppColors.primary,
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip(
                              label: student.status.name,
                              color: student.status == StudentStatus.active
                                  ? AppColors.primary
                                  : AppColors.outline,
                              textColor: student.status == StudentStatus.active
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'ID: ${student.studentId}',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Name
                    Text(
                      student.name,
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Chips (Grade, Stream, Blood Group)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        if (student.grade != null)
                          _buildCardChip(
                            context,
                            '${student.grade} - Section ${student.section ?? "A"}',
                            isDark,
                          ),
                        if (student.stream != null)
                          _buildCardChip(context, student.stream!, isDark),
                        if (student.bloodGroup != null)
                          _buildCardChip(context, '🩸 ${student.bloodGroup}', isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              
              // QR Code
              QrCodeWidget(
                data: student.studentId,
                size: 80.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardChip(BuildContext context, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLowDark : AppColors.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.regular),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
