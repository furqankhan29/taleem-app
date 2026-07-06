import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsSnapshotModel {
  final String id;
  final String period;
  final DateTime timestamp;
  final int totalStudents;
  final int activeStudents;
  final int totalTeachers;
  final int totalBatches;
  final double attendanceRate;
  final double feeCollectionRate;
  final double totalRevenue;
  final double outstandingFees;
  final int overdueFees;
  final int feeDefaulters;
  final Map<String, double> monthlyRevenue;
  final Map<String, double> attendanceByBatch;
  final Map<String, int> studentStatusBreakdown;
  final Map<String, dynamic> additionalMetrics;

  const AnalyticsSnapshotModel({
    required this.id,
    required this.period,
    required this.timestamp,
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.totalTeachers = 0,
    this.totalBatches = 0,
    this.attendanceRate = 0.0,
    this.feeCollectionRate = 0.0,
    this.totalRevenue = 0.0,
    this.outstandingFees = 0.0,
    this.overdueFees = 0,
    this.feeDefaulters = 0,
    this.monthlyRevenue = const {},
    this.attendanceByBatch = const {},
    this.studentStatusBreakdown = const {},
    this.additionalMetrics = const {},
  });

  factory AnalyticsSnapshotModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSnapshotModel(
      id: json['id'] as String? ?? '',
      period: json['period'] as String? ?? '',
      timestamp: _parseDateTime(json['timestamp']),
      totalStudents: json['totalStudents'] as int? ?? 0,
      activeStudents: json['activeStudents'] as int? ?? 0,
      totalTeachers: json['totalTeachers'] as int? ?? 0,
      totalBatches: json['totalBatches'] as int? ?? 0,
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      feeCollectionRate: (json['feeCollectionRate'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      outstandingFees: (json['outstandingFees'] as num?)?.toDouble() ?? 0.0,
      overdueFees: json['overdueFees'] as int? ?? 0,
      feeDefaulters: json['feeDefaulters'] as int? ?? 0,
      monthlyRevenue: Map<String, double>.from(
        (json['monthlyRevenue'] as Map?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ?? {},
      ),
      attendanceByBatch: Map<String, double>.from(
        (json['attendanceByBatch'] as Map?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ?? {},
      ),
      studentStatusBreakdown: Map<String, int>.from(
        (json['studentStatusBreakdown'] as Map?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ?? {},
      ),
      additionalMetrics: Map<String, dynamic>.from(
        json['additionalMetrics'] as Map? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'timestamp': Timestamp.fromDate(timestamp),
      'totalStudents': totalStudents,
      'activeStudents': activeStudents,
      'totalTeachers': totalTeachers,
      'totalBatches': totalBatches,
      'attendanceRate': attendanceRate,
      'feeCollectionRate': feeCollectionRate,
      'totalRevenue': totalRevenue,
      'outstandingFees': outstandingFees,
      'overdueFees': overdueFees,
      'feeDefaulters': feeDefaulters,
      'monthlyRevenue': monthlyRevenue,
      'attendanceByBatch': attendanceByBatch,
      'studentStatusBreakdown': studentStatusBreakdown,
      'additionalMetrics': additionalMetrics,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
