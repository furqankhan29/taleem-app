import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/timetable_model.dart';

class TimetableRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TimetableModel>> streamTimetables({String? batchId}) {
    Query query = _firestore.collection(FirebasePaths.timetable);
    if (batchId != null) {
      query = query.where('batchId', isEqualTo: batchId);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Future<List<TimetableModel>> getTimetables({String? batchId}) async {
    Query query = _firestore.collection(FirebasePaths.timetable);
    if (batchId != null) {
      query = query.where('batchId', isEqualTo: batchId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<TimetableModel?> getById(String id) async {
    final doc = await _firestore.collection(FirebasePaths.timetable).doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Stream<TimetableModel?> streamById(String id) {
    return _firestore.collection(FirebasePaths.timetable).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  Future<List<TimetableModel>> getByDay(int dayOfWeek, {String? batchId}) async {
    Query query = _firestore.collection(FirebasePaths.timetable)
        .where('dayOfWeek', isEqualTo: dayOfWeek);
    if (batchId != null) {
      query = query.where('batchId', isEqualTo: batchId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<void> save(TimetableModel model) async {
    await _firestore.collection(FirebasePaths.timetable).doc(model.id).set(model.toJson());
  }

  Future<void> update(TimetableModel model) async {
    await _firestore.collection(FirebasePaths.timetable).doc(model.id).update(model.toJson());
  }

  Future<void> delete(String id) async {
    await _firestore.collection(FirebasePaths.timetable).doc(id).delete();
  }

  TimetableModel _fromDoc(DocumentSnapshot doc) {
    return TimetableModel.fromJson(Map<String, dynamic>.from(doc.data() as Map));
  }
}
