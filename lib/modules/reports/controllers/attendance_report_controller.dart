import 'package:get/get.dart';
import 'package:taleem/core/services/local_report_service.dart';
import 'package:taleem/core/services/report_service.dart';

class AttendanceReportController extends GetxController {
  final BaseReportService _reportService = Get.find<LocalReportService>();

  final loading = true.obs;
  final error = RxnString();
  final analytics = Rxn<AnalyticsData>();
  final filter = ReportFilter().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void setFilter(ReportFilter newFilter) {
    filter.value = newFilter;
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    error.value = null;
    try {
      analytics.value = await _reportService.getAttendanceAnalytics(filter: filter.value);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
