import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/calendar_event_model.dart';
import 'package:taleem/data/repositories/calendar_repository.dart';

class CalendarController extends GetxController {
  final CalendarRepository _repository = Get.find<CalendarRepository>();

  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> focusedMonth = DateTime.now().obs;

  final RxSet<DateTime> eventDates = <DateTime>{}.obs;

  List<CalendarEventModel> get upcomingEvents {
    final now = DateTime.now();
    return events.where((e) => e.date.isAfter(now.subtract(const Duration(days: 1))))
        .toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CalendarEventModel> eventsForDay(DateTime day) {
    return events.where((e) =>
        e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents({String? userId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getEvents(userId: userId);
      events.assignAll(data);
      _rebuildEventDates();
    } catch (e) {
      errorMessage.value = ErrorHandler.handleError(e).message;
      Helpers.showSnackbar(title: 'Error', message: errorMessage.value, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void goToPreviousMonth() {
    focusedMonth.value = DateTime(focusedMonth.value.year, focusedMonth.value.month - 1);
  }

  void goToNextMonth() {
    focusedMonth.value = DateTime(focusedMonth.value.year, focusedMonth.value.month + 1);
  }

  Future<void> addEvent(CalendarEventModel model) async {
    try {
      await _repository.save(model);
      events.add(model);
      _rebuildEventDates();
      Helpers.showSnackbar(title: 'Success', message: 'Event created');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> updateEvent(CalendarEventModel model) async {
    try {
      await _repository.update(model);
      final idx = events.indexWhere((e) => e.id == model.id);
      if (idx != -1) events[idx] = model;
      _rebuildEventDates();
      Helpers.showSnackbar(title: 'Success', message: 'Event updated');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.delete(id);
      events.removeWhere((e) => e.id == id);
      _rebuildEventDates();
      Helpers.showSnackbar(title: 'Deleted', message: 'Event removed');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  void _rebuildEventDates() {
    eventDates.clear();
    eventDates.addAll(events.map((e) =>
        DateTime(e.date.year, e.date.month, e.date.day)));
  }

  Color colorForEventType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.holiday:
        return Colors.green;
      case CalendarEventType.exam:
        return Colors.red;
      case CalendarEventType.ptm:
        return Colors.orange;
      case CalendarEventType.deadline:
        return Colors.purple;
      case CalendarEventType.event:
        return Colors.blue;
    }
  }

  IconData iconForEventType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.holiday:
        return Icons.celebration;
      case CalendarEventType.exam:
        return Icons.quiz;
      case CalendarEventType.ptm:
        return Icons.groups;
      case CalendarEventType.deadline:
        return Icons.schedule;
      case CalendarEventType.event:
        return Icons.event;
    }
  }
}
