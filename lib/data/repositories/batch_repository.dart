import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/batch_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class BatchRepository extends BaseRepository<BatchModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BatchRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.batches);

  @override
  BatchModel fromJson(Map<String, dynamic> json) => BatchModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(BatchModel model) => model.toJson();

  @override
  String getModelId(BatchModel model) => model.id;

  Future<QuerySnapshot<Map<String, dynamic>>> queryBatches({
    String? searchQuery,
    BatchSchedule? schedule,
    BatchStatus? status,
    String? teacherId,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.batches);

    if (schedule != null) {
      query = query.where('schedule', isEqualTo: schedule.name);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (teacherId != null && teacherId.isNotEmpty) {
      query = query.where('teacherId', isEqualTo: teacherId);
    }

    final sortField = sortByField ?? 'name';
    query = query.orderBy(sortField, descending: descending);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final searchVal = searchQuery.trim();
      query = query
          .where('name', isGreaterThanOrEqualTo: searchVal)
          .where('name', isLessThanOrEqualTo: '$searchVal\uf8ff');
    }

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return await query.limit(limit).get();
  }

  Future<int> getBatchCount() async {
    final snap = await _firestore.collection(FirebasePaths.batches).count().get();
    return snap.count ?? 0;
  }

  Future<List<BatchModel>> getBatchesByTeacherId(String teacherId) async {
    final snap = await _firestore
        .collection(FirebasePaths.batches)
        .where('teacherId', isEqualTo: teacherId)
        .get();
    return snap.docs.map((doc) => BatchModel.fromJson(doc.data())).toList();
  }

  Future<List<BatchModel>> getBatchesByStudentId(String studentId) async {
    final snap = await _firestore
        .collection(FirebasePaths.batches)
        .where('studentIds', arrayContains: studentId)
        .get();
    return snap.docs.map((doc) => BatchModel.fromJson(doc.data())).toList();
  }
}
