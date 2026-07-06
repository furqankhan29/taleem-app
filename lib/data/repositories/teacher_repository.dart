import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/teacher_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class TeacherRepository extends BaseRepository<TeacherModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TeacherRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.teachers);

  @override
  TeacherModel fromJson(Map<String, dynamic> json) => TeacherModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(TeacherModel model) => model.toJson();

  @override
  String getModelId(TeacherModel model) => model.id;

  Future<QuerySnapshot<Map<String, dynamic>>> queryTeachers({
    String? searchQuery,
    TeacherStatus? status,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.teachers);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
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

  Future<int> getTeacherCount() async {
    final snap = await _firestore.collection(FirebasePaths.teachers).count().get();
    return snap.count ?? 0;
  }
}
