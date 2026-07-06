import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/parent_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class ParentRepository extends BaseRepository<ParentModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ParentRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.parents);

  @override
  ParentModel fromJson(Map<String, dynamic> json) => ParentModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ParentModel model) => model.toJson();

  @override
  String getModelId(ParentModel model) => model.id;

  Future<QuerySnapshot<Map<String, dynamic>>> queryParents({
    String? searchQuery,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.parents);

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

  Future<int> getParentCount() async {
    final snap = await _firestore.collection(FirebasePaths.parents).count().get();
    return snap.count ?? 0;
  }

  Future<List<ParentModel>> getParentsByStudentId(String studentId) async {
    final snap = await _firestore
        .collection(FirebasePaths.parents)
        .where('studentIds', arrayContains: studentId)
        .get();
    return snap.docs.map((doc) => ParentModel.fromJson(doc.data())).toList();
  }
}
