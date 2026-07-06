import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class StudentRepository extends BaseRepository<StudentModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.students);

  @override
  StudentModel fromJson(Map<String, dynamic> json) => StudentModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(StudentModel model) => model.toJson();

  @override
  String getModelId(StudentModel model) => model.id;

  // Optimized query for paginated student lists with filters, search, and sorting
  Future<QuerySnapshot<Map<String, dynamic>>> queryStudents({
    String? searchQuery,
    String? grade,
    StudentStatus? status,
    FeeStatus? feeStatus,
    String? sortByField,
    bool descending = false,
    DocumentSnapshot? startAfterDoc,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(FirebasePaths.students);

    // Apply Filters
    if (grade != null && grade.isNotEmpty) {
      query = query.where('grade', isEqualTo: grade);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (feeStatus != null) {
      query = query.where('feeStatus', isEqualTo: feeStatus.name);
    }

    // Apply Sorting (Firestore requires sorting field to be queried if using ranges, but for basic lists we sort by name or createdAt)
    final sortField = sortByField ?? 'name';
    query = query.orderBy(sortField, descending: descending);

    // If search query exists, we do a client-side filter or simple prefix match in production.
    // For Firestore prefix query we do: name >= query and name <= query + '\uf8ff'
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final searchVal = searchQuery.trim();
      query = query
          .where('name', isGreaterThanOrEqualTo: searchVal)
          .where('name', isLessThanOrEqualTo: '$searchVal\uf8ff');
    }

    // Pagination
    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return await query.limit(limit).get();
  }

  // Get total student count
  Future<int> getStudentCount() async {
    final snap = await _firestore.collection(FirebasePaths.students).count().get();
    return snap.count ?? 0;
  }
}
