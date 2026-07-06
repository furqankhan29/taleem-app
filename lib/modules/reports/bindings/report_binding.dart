import 'package:get/get.dart';
import 'package:taleem/core/services/export_service.dart';
import 'package:taleem/core/services/local_report_service.dart';
import 'package:taleem/modules/reports/controllers/analytics_controller.dart';
import 'package:taleem/modules/reports/controllers/attendance_report_controller.dart';
import 'package:taleem/modules/reports/controllers/fee_report_controller.dart';
import 'package:taleem/modules/reports/controllers/student_report_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalReportService>(() => LocalReportService());
    Get.lazyPut<ExportService>(() => ExportService());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
    Get.lazyPut<AttendanceReportController>(() => AttendanceReportController());
    Get.lazyPut<FeeReportController>(() => FeeReportController());
    Get.lazyPut<StudentReportController>(() => StudentReportController());
  }
}
