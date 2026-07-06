import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taleem/core/theme/app_colors.dart';
import 'package:taleem/core/theme/app_typography.dart';
import 'package:taleem/data/models/calendar_event_model.dart';
import 'package:taleem/modules/calendar/controllers/calendar_controller.dart';
import 'package:taleem/modules/calendar/views/widgets/event_card.dart';
import 'package:taleem/shared/widgets/empty_state.dart';
import 'package:taleem/shared/widgets/error_state.dart';
import 'package:taleem/shared/widgets/section_header.dart';
import 'package:taleem/shared/widgets/shimmer_loading.dart';

class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoading();
        if (controller.errorMessage.isNotEmpty) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: () => controller.loadEvents(),
          );
        }
        return _buildContent();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerLoading(width: double.infinity, height: 100, borderRadius: 12),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildMonthHeader(),
        _buildCalendarGrid(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(
            title: 'Upcoming Events',
            actionLabel: controller.upcomingEvents.length > 3 ? 'See All' : null,
          ),
        ),
        Expanded(child: _buildEventsList()),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceContainerLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.goToPreviousMonth,
          ),
          Obx(() => Text(
            DateFormat('MMMM yyyy').format(controller.focusedMonth.value),
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          )),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.goToNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Obx(() {
      final month = controller.focusedMonth.value;
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final firstWeekday = DateTime(month.year, month.month, 1).weekday - 1;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((d) => SizedBox(
                        width: 32,
                        child: Text(d, textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (_, i) {
                if (i < firstWeekday) return const SizedBox();
                final day = i - firstWeekday + 1;
                final date = DateTime(month.year, month.month, day);
                final hasEvent = controller.eventDates.contains(date);
                final isToday = _isSameDay(date, DateTime.now());
                return _buildDayCell(day, hasEvent, isToday);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDayCell(int day, bool hasEvent, bool isToday) {
    return GestureDetector(
      onTap: () {
        _showDayEvents(DateTime(
          controller.focusedMonth.value.year,
          controller.focusedMonth.value.month,
          day,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? AppColors.primaryContainer : null,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? AppColors.onPrimaryContainer : AppColors.onSurface,
                ),
              ),
              if (hasEvent)
                Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    final upcoming = controller.upcomingEvents;
    if (upcoming.isEmpty) {
      return const EmptyState(
        icon: Icons.event_note,
        title: 'No Upcoming Events',
        subtitle: 'There are no events scheduled yet',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: upcoming.length,
      itemBuilder: (_, i) => EventCard(
        event: upcoming[i],
        onTap: () => _showEventDetail(upcoming[i]),
      ),
    );
  }

  void _showDayEvents(DateTime day) {
    final events = controller.eventsForDay(day);
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
            const SizedBox(height: 16),
            Text(DateFormat('EEEE, MMM d').format(day),
                style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No events on this day')),
              )
            else
              ...events.map((e) => EventCard(event: e)),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(CalendarEventModel event) {
    final dateFormat = DateFormat('MMM d, yyyy');
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
            Row(children: [
              Icon(controller.iconForEventType(event.type), color: controller.colorForEventType(event.type)),
              const SizedBox(width: 8),
              Text(event.type.name.toUpperCase(),
                  style: AppTypography.labelCaps.copyWith(color: controller.colorForEventType(event.type))),
            ]),
            const SizedBox(height: 8),
            Text(event.title, style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(dateFormat.format(event.date),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
            ]),
            if (event.endDate != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.date_range, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(dateFormat.format(event.endDate!),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ]),
            ],
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(event.description!, style: AppTypography.bodyMedium),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.deleteEvent(event.id),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDialog() {
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final selectedType = Rx<CalendarEventType>(CalendarEventType.event);
    final selectedDate = Rx<DateTime>(DateTime.now());
    final selectedEndDate = Rxn<DateTime>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
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
              Text('New Event', style: AppTypography.headlineMedium),
              const SizedBox(height: 16),
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<CalendarEventType>(
                value: selectedType.value,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: CalendarEventType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name),
                )).toList(),
                onChanged: (v) { if (v != null) selectedType.value = v; },
              )),
              const SizedBox(height: 12),
              Obx(() => InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) selectedDate.value = picked;
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                  child: Text(DateFormat('MMM d, yyyy').format(selectedDate.value)),
                ),
              )),
              const SizedBox(height: 12),
              Obx(() => InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedEndDate.value ?? selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) selectedEndDate.value = picked;
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'End Date (optional)', border: OutlineInputBorder()),
                  child: Text(selectedEndDate.value != null
                      ? DateFormat('MMM d, yyyy').format(selectedEndDate.value!)
                      : 'Tap to select'),
                ),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleC.text.trim().isEmpty) return;
                    controller.addEvent(CalendarEventModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleC.text.trim(),
                      description: descC.text.trim().isEmpty ? null : descC.text.trim(),
                      date: selectedDate.value,
                      endDate: selectedEndDate.value,
                      type: selectedType.value,
                    ));
                    Get.back();
                  },
                  child: const Text('Add Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
