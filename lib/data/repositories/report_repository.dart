import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/analytics_snapshot_model.dart';
import 'package:taleem/data/models/export_log_model.dart';
import 'package:taleem/data/models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReportModel>> streamReports({String? userId}) {
    Query query = _firestore.collection(FirebasePaths.reports).orderBy('generatedAt', descending: true);
    if (userId != null) {
      query = query.where('generatedBy', isEqualTo: userId);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => ReportModel.fromJson(Map<String, dynamic>.from(doc.data() as Map))).toList());
  }

  Future<List<ReportModel>> getReports({String? userId, int limit = 20}) async {
    Query query = _firestore.collection(FirebasePaths.reports).orderBy('generatedAt', descending: true).limit(limit);
    if (userId != null) {
      query = query.where('generatedBy', isEqualTo: userId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => ReportModel.fromJson(Map<String, dynamic>.from(doc.data() as Map))).toList();
  }

  Future<void> saveReport(ReportModel report) async {
    await _firestore.collection(FirebasePaths.reports).doc(report.id).set(report.toJson());
  }

  Future<void> deleteReport(String id) async {
    await _firestore.collection(FirebasePaths.reports).doc(id).delete();
  }

  Stream<List<ExportLogModel>> streamExportLogs() {
    return _firestore
        .collection(FirebasePaths.exportLogs)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ExportLogModel.fromJson(Map<String, dynamic>.from(doc.data() as Map))).toList());
  }

  Future<void> saveExportLog(ExportLogModel log) async {
    await _firestore.collection(FirebasePaths.exportLogs).doc(log.id).set(log.toJson());
  }

  Future<void> saveAnalyticsSnapshot(AnalyticsSnapshotModel snapshot) async {
    await _firestore.collection(FirebasePaths.analyticsSnapshots).doc(snapshot.id).set(snapshot.toJson());
  }

  Stream<List<AnalyticsSnapshotModel>> streamAnalyticsSnapshots({int limit = 12}) {
    return _firestore
        .collection(FirebasePaths.analyticsSnapshots)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => AnalyticsSnapshotModel.fromJson(Map<String, dynamic>.from(doc.data() as Map))).toList());
  }

  Future<AnalyticsSnapshotModel?> getLatestSnapshot() async {
    final snap = await _firestore
        .collection(FirebasePaths.analyticsSnapshots)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return AnalyticsSnapshotModel.fromJson(Map<String, dynamic>.from(snap.docs.first.data() as Map));
    }
    return null;
  }
}
