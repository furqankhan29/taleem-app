import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/exam_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class ExamRepository extends BaseRepository<ExamModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ExamRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.exams);

  @override
  ExamModel fromJson(Map<String, dynamic> json) => ExamModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ExamModel model) => model.toJson();

  @override
  String getModelId(ExamModel model) => model.id;

  Future<QuerySnapshot<Map<String, dynamic>>> queryExams({
    String? searchQuery,
    String? batchId,
    String? subjectId,
    ExamStatus? status,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.exams);

    if (batchId != null && batchId.isNotEmpty) {
      query = query.where('batchId', isEqualTo: batchId);
    }
    if (subjectId != null && subjectId.isNotEmpty) {
      query = query.where('subjectId', isEqualTo: subjectId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    final sortField = sortByField ?? 'date';
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

  Future<int> getExamCount() async {
    final snap = await _firestore.collection(FirebasePaths.exams).count().get();
    return snap.count ?? 0;
  }
}
