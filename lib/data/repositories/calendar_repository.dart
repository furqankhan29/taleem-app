import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/calendar_event_model.dart';

class CalendarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CalendarEventModel>> streamEvents({String? userId}) {
    Query query = _firestore.collection(FirebasePaths.calendarEvents).orderBy('date', descending: false);
    if (userId != null) {
      query = query.where('participants', arrayContains: userId);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Future<List<CalendarEventModel>> getEvents({String? userId, int limit = 50}) async {
    Query query = _firestore.collection(FirebasePaths.calendarEvents)
        .orderBy('date', descending: false)
        .limit(limit);
    if (userId != null) {
      query = query.where('participants', arrayContains: userId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<List<CalendarEventModel>> getEventsByDateRange({
    required DateTime start,
    required DateTime end,
    String? userId,
  }) async {
    Query query = _firestore.collection(FirebasePaths.calendarEvents)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: false);
    if (userId != null) {
      query = query.where('participants', arrayContains: userId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<List<CalendarEventModel>> getByType(String type, {String? userId}) async {
    Query query = _firestore.collection(FirebasePaths.calendarEvents)
        .where('type', isEqualTo: type)
        .orderBy('date', descending: false);
    if (userId != null) {
      query = query.where('participants', arrayContains: userId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<void> save(CalendarEventModel model) async {
    await _firestore.collection(FirebasePaths.calendarEvents).doc(model.id).set(model.toJson());
  }

  Future<void> update(CalendarEventModel model) async {
    await _firestore.collection(FirebasePaths.calendarEvents).doc(model.id).update(model.toJson());
  }

  Future<void> delete(String id) async {
    await _firestore.collection(FirebasePaths.calendarEvents).doc(id).delete();
  }

  CalendarEventModel _fromDoc(DocumentSnapshot doc) {
    return CalendarEventModel.fromJson(Map<String, dynamic>.from(doc.data() as Map));
  }
}
