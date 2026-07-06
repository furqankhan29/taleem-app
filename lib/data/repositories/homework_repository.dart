import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/homework_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class HomeworkRepository extends BaseRepository<HomeworkModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeworkRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.homework);

  @override
  HomeworkModel fromJson(Map<String, dynamic> json) => HomeworkModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(HomeworkModel model) => model.toJson();

  @override
  String getModelId(HomeworkModel model) => model.id;

  Future<QuerySnapshot<Map<String, dynamic>>> queryHomework({
    String? searchQuery,
    String? batchId,
    String? subjectId,
    String? teacherId,
    HomeworkStatus? status,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.homework);

    if (batchId != null && batchId.isNotEmpty) {
      query = query.where('batchId', isEqualTo: batchId);
    }
    if (subjectId != null && subjectId.isNotEmpty) {
      query = query.where('subjectId', isEqualTo: subjectId);
    }
    if (teacherId != null && teacherId.isNotEmpty) {
      query = query.where('teacherId', isEqualTo: teacherId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    final sortField = sortByField ?? 'dueDate';
    query = query.orderBy(sortField, descending: descending);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final searchVal = searchQuery.trim();
      query = query
          .where('title', isGreaterThanOrEqualTo: searchVal)
          .where('title', isLessThanOrEqualTo: '$searchVal\uf8ff');
    }

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return await query.limit(limit).get();
  }

  Future<int> getHomeworkCount() async {
    final snap = await _firestore.collection(FirebasePaths.homework).count().get();
    return snap.count ?? 0;
  }
}
