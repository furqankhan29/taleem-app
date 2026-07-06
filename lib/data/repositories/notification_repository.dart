import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> streamNotifications({
    String? userId,
    String? role,
    int limit = 50,
  }) {
    Query query = _firestore.collection(FirebasePaths.notifications)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (userId != null) {
      query = query.where('recipientIds', arrayContains: userId);
    }
    if (role != null) {
      query = query.where('recipientRoles', arrayContains: role);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Future<List<NotificationModel>> getNotifications({
    String? userId,
    String? role,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore.collection(FirebasePaths.notifications)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (userId != null) {
      query = query.where('recipientIds', arrayContains: userId);
    }
    if (role != null) {
      query = query.where('recipientRoles', arrayContains: role);
    }
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<List<NotificationModel>> getByType(String type, {String? userId}) async {
    Query query = _firestore.collection(FirebasePaths.notifications)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true);
    if (userId != null) {
      query = query.where('recipientIds', arrayContains: userId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<void> save(NotificationModel model) async {
    await _firestore.collection(FirebasePaths.notifications).doc(model.id).set(model.toJson());
  }

  Future<void> update(NotificationModel model) async {
    await _firestore.collection(FirebasePaths.notifications).doc(model.id).update(model.toJson());
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection(FirebasePaths.notifications).doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead({String? userId}) async {
    Query query = _firestore.collection(FirebasePaths.notifications)
        .where('isRead', isEqualTo: false);
    if (userId != null) {
      query = query.where('recipientIds', arrayContains: userId);
    }
    final snap = await query.get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> delete(String id) async {
    await _firestore.collection(FirebasePaths.notifications).doc(id).delete();
  }

  Stream<int> streamUnreadCount({String? userId}) {
    Query query = _firestore.collection(FirebasePaths.notifications)
        .where('isRead', isEqualTo: false);
    if (userId != null) {
      query = query.where('recipientIds', arrayContains: userId);
    }
    return query.snapshots().map((snap) => snap.docs.length);
  }

  NotificationModel _fromDoc(DocumentSnapshot doc) {
    return NotificationModel.fromJson(Map<String, dynamic>.from(doc.data() as Map));
  }
}
