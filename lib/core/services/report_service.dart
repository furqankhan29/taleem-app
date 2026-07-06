import 'package:get/get.dart';
import 'package:taleem/data/models/report_model.dart';

enum ReportPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  custom;

  String get label {
    switch (this) {
      case ReportPeriod.daily: return 'Daily';
      case ReportPeriod.weekly: return 'Weekly';
      case ReportPeriod.monthly: return 'Monthly';
      case ReportPeriod.quarterly: return 'Quarterly';
      case ReportPeriod.yearly: return 'Yearly';
      case ReportPeriod.custom: return 'Custom';
    }
  }
}

class ReportFilter {
  final ReportPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? batchId;
  final String? studentId;
  final String? teacherId;
  final String? grade;
  final String? searchQuery;

  const ReportFilter({
    this.period = ReportPeriod.monthly,
    this.startDate,
    this.endDate,
    this.batchId,
    this.studentId,
    this.teacherId,
    this.grade,
    this.searchQuery,
  });

  ReportFilter copyWith({
    ReportPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    String? batchId,
    String? studentId,
    String? teacherId,
    String? grade,
    String? searchQuery,
  }) {
    return ReportFilter(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      batchId: batchId ?? this.batchId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      grade: grade ?? this.grade,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AnalyticsData {
  final Map<String, dynamic> metrics;
  final List<Map<String, dynamic>> charts;
  final List<Map<String, dynamic>> tables;
  final String? aiInsight;

  const AnalyticsData({
    this.metrics = const {},
    this.charts = const [],
    this.tables = const [],
    this.aiInsight,
  });
}

abstract class BaseReportService extends GetxService {
  Future<AnalyticsData> getInstituteAnalytics({ReportFilter? filter});

  Future<AnalyticsData> getAttendanceAnalytics({ReportFilter? filter});

  Future<AnalyticsData> getFeeAnalytics({ReportFilter? filter});

  Future<AnalyticsData> getStudentAnalytics({ReportFilter? filter});

  Future<AnalyticsData> getRevenueAnalytics({ReportFilter? filter});

  Future<List<Map<String, dynamic>>> getKpiMetrics({ReportFilter? filter});

  Future<ReportModel> generateReport({
    required String title,
    required ReportType type,
    required DateRange dateRange,
  });

  Future<String> generateAiInsight({required ReportType type, required Map<String, dynamic> data});
}
