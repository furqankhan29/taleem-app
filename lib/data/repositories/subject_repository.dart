import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/subject_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class SubjectRepository extends BaseRepository<SubjectModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SubjectRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.subjects);

  @override
  SubjectModel fromJson(Map<String, dynamic> json) => SubjectModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(SubjectModel model) => model.toJson();

  @override
  String getModelId(SubjectModel model) => model.id;

  Future<QuerySnapshot<Map<String, dynamic>>> querySubjects({
    String? searchQuery,
    String? gradeLevel,
    String? category,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.subjects);

    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      query = query.where('gradeLevel', isEqualTo: gradeLevel);
    }
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
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

  Future<int> getSubjectCount() async {
    final snap = await _firestore.collection(FirebasePaths.subjects).count().get();
    return snap.count ?? 0;
  }
}
