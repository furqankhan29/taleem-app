import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/modules/timetable/controllers/timetable_controller.dart';
import 'package:taleem/modules/timetable/views/widgets/timetable_slot_card.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/error_state.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';

class TimetableScreen extends GetView<TimetableController> {
  const TimetableScreen({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _fullDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoading();
        if (controller.errorMessage.isNotEmpty) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: () => controller.refresh(),
          );
        }
        if (controller.timetables.isEmpty) {
          return const EmptyState(
            icon: Icons.calendar_view_week,
            title: 'No Timetable',
            subtitle: 'No timetable has been set up yet',
          );
        }
        return _buildTimetableGrid();
      }),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoading(width: double.infinity, height: 80, borderRadius: 12),
      ),
    );
  }

  Widget _buildTimetableGrid() {
    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceContainerLow,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              tabs: _days.map((d) => Tab(text: d)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(7, (i) {
                final dayOfWeek = i + 1;
                final slots = controller.slotsForDay(dayOfWeek);
                return _buildDayView(dayOfWeek, slots);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(int dayOfWeek, List<dynamic> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            _fullDays[dayOfWeek - 1],
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (slots.isEmpty)
          const Expanded(
            child: EmptyState(
              icon: Icons.free_breakfast,
              title: 'No Classes',
              subtitle: 'No classes scheduled for this day',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: slots.length,
              itemBuilder: (_, i) {
                final slot = slots[i] as dynamic;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TimetableSlotCard(
                    slot: slot,
                    onTap: () => _showSlotSheet(slot),
                    accentColor: _colorForIndex(i),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showSlotSheet(dynamic slot) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(slot.subjectName, style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '${slot.startTime} - ${slot.endTime}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            if (slot.teacherName != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.person, size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(slot.teacherName, style: AppTypography.bodyMedium),
              ]),
            ],
            if (slot.room != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.meeting_room, size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(slot.room, style: AppTypography.bodyMedium),
              ]),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _colorForIndex(int i) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      Color(0xFF2E7D32),
      Color(0xFF6A1B9A),
      Color(0xFFE65100),
      Color(0xFF00838F),
    ];
    return colors[i % colors.length];
  }
}
