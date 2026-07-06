import 'package:get/get.dart';
import 'package:taleem/core/services/export_service.dart';
import 'package:taleem/core/services/local_report_service.dart';
import 'package:taleem/core/services/report_service.dart';
import 'package:taleem/data/models/export_log_model.dart';
import 'package:taleem/data/models/report_model.dart';
import 'package:taleem/data/repositories/report_repository.dart';

class ExportController extends GetxController {
  final ExportService _exportService = Get.find<ExportService>();
  final BaseReportService _reportService = Get.find<LocalReportService>();
  final ReportRepository _repository = ReportRepository();

  final exporting = false.obs;
  final exportLogs = <ExportLogModel>[].obs;
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _repository.streamExportLogs().listen((logs) {
      exportLogs.value = logs;
      loading.value = false;
    });
  }

  Future<void> exportToPdf({
    required String title,
    required ReportType type,
    required Map<String, dynamic> data,
    ReportFilter? filter,
  }) async {
    exporting.value = true;
    try {
      final dateRange = DateRange(
        start: filter?.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: filter?.endDate ?? DateTime.now(),
      );

      final report = await _reportService.generateReport(
        title: title,
        type: type,
        dateRange: dateRange,
      );

      final log = await _exportService.exportToPdf(
        title: title,
        data: data,
        type: type,
      );

      await _repository.saveReport(report);
      await _repository.saveExportLog(log);

      if (log.filePath != null) {
        Helpers.showSnackbar(
          title: 'Exported',
          message: 'PDF saved successfully',
        );
      }
    } catch (e) {
      Helpers.showSnackbar(
        title: 'Export Failed',
        message: e.toString(),
        isError: true,
      );
    } finally {
      exporting.value = false;
    }
  }

  Future<void> exportToExcel({
    required String title,
    required List<Map<String, dynamic>> rows,
    required List<String> columns,
    ReportFilter? filter,
  }) async {
    exporting.value = true;
    try {
      final log = await _exportService.exportToExcel(
        title: title,
        rows: rows,
        columns: columns,
      );
      await _repository.saveExportLog(log);

      if (log.filePath != null) {
        Helpers.showSnackbar(
          title: 'Exported',
          message: 'Excel saved successfully',
        );
      }
    } catch (e) {
      Helpers.showSnackbar(
        title: 'Export Failed',
        message: e.toString(),
        isError: true,
      );
    } finally {
      exporting.value = false;
    }
  }

  Future<void> shareFile(String filePath, String title) async {
    await _exportService.shareFile(filePath, title);
  }
}

class Helpers {
  static void showSnackbar({required String title, required String message, bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Get.theme.colorScheme.error : Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }
}
