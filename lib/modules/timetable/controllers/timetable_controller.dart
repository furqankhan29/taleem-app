import 'package:get/get.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/timetable_model.dart';
import 'package:taleem/data/repositories/timetable_repository.dart';

class TimetableController extends GetxController {
  final TimetableRepository _repository = Get.find<TimetableRepository>();

  final RxList<TimetableModel> timetables = <TimetableModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedBatchId = ''.obs;

  Map<int, List<TimetableSlot>> get groupedByDay {
    final map = <int, List<TimetableSlot>>{};
    for (final tt in timetables) {
      map.putIfAbsent(tt.dayOfWeek, () => tt.slots);
    }
    return map;
  }

  List<TimetableSlot> slotsForDay(int dayOfWeek) {
    final idx = timetables.indexWhere((t) => t.dayOfWeek == dayOfWeek);
    if (idx == -1) return [];
    return timetables[idx].slots;
  }

  @override
  void onInit() {
    super.onInit();
    loadTimetables();
  }

  Future<void> loadTimetables({String? batchId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final bId = batchId ?? (selectedBatchId.value.isEmpty ? null : selectedBatchId.value);
      final data = await _repository.getTimetables(batchId: bId);
      timetables.assignAll(data);
    } catch (e) {
      errorMessage.value = ErrorHandler.handleError(e).message;
      Helpers.showSnackbar(title: 'Error', message: errorMessage.value, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh({String? batchId}) async {
    if (batchId != null) selectedBatchId.value = batchId;
    await loadTimetables(batchId: batchId);
  }

  Future<void> addTimetable(TimetableModel model) async {
    try {
      await _repository.save(model);
      timetables.add(model);
      Helpers.showSnackbar(title: 'Success', message: 'Timetable added');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> updateTimetable(TimetableModel model) async {
    try {
      await _repository.update(model);
      final idx = timetables.indexWhere((t) => t.id == model.id);
      if (idx != -1) timetables[idx] = model;
      Helpers.showSnackbar(title: 'Success', message: 'Timetable updated');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }

  Future<void> deleteTimetable(String id) async {
    try {
      await _repository.delete(id);
      timetables.removeWhere((t) => t.id == id);
      Helpers.showSnackbar(title: 'Deleted', message: 'Timetable removed');
    } catch (e) {
      Helpers.showSnackbar(title: 'Error', message: ErrorHandler.handleError(e).message, isError: true);
    }
  }
}
