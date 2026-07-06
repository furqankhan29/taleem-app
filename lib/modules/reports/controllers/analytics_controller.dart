import 'package:get/get.dart';
import 'package:taleem/core/services/local_report_service.dart';
import 'package:taleem/core/services/report_service.dart';

class AnalyticsController extends GetxController {
  final BaseReportService _reportService = Get.find<LocalReportService>();

  final loading = true.obs;
  final error = RxnString();
  final analytics = Rxn<AnalyticsData>();
  final kpiMetrics = <Map<String, dynamic>>[].obs;
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

  void resetFilter() {
    filter.value = const ReportFilter();
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        _reportService.getInstituteAnalytics(filter: filter.value),
        _reportService.getKpiMetrics(filter: filter.value),
      ]);
      analytics.value = results[0] as AnalyticsData;
      kpiMetrics.value = results[1] as List<Map<String, dynamic>>;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
