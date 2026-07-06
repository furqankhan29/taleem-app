import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class FeeRepository extends BaseRepository<FeeModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FeeRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.fees);

  @override
  FeeModel fromJson(Map<String, dynamic> json) => FeeModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(FeeModel model) => model.toJson();

  @override
  String getModelId(FeeModel model) => model.id;

  // Fetch all fees for a specific student
  Future<List<FeeModel>> getStudentFees(String studentId) async {
    final snap = await _firestore
        .collection(FirebasePaths.fees)
        .where('studentId', isEqualTo: studentId)
        .orderBy('dueDate', descending: true)
        .get();

    return snap.docs.map((doc) => FeeModel.fromJson(doc.data())).toList();
  }

  // Get outstanding balance (total pending / overdue fees)
  Future<double> getOutstandingBalance() async {
    final snap = await _firestore
        .collection(FirebasePaths.fees)
        .where('status', whereIn: [FeePaymentStatus.pending.name, FeePaymentStatus.partial.name, FeePaymentStatus.overdue.name])
        .get();

    double total = 0.0;
    for (final doc in snap.docs) {
      final model = FeeModel.fromJson(doc.data());
      total += model.balanceDue;
    }
    return total;
  }

  // Get total collected income
  Future<double> getTotalCollectedIncome() async {
    final snap = await _firestore.collection(FirebasePaths.fees).get();
    double total = 0.0;
    for (final doc in snap.docs) {
      final model = FeeModel.fromJson(doc.data());
      total += model.totalPaid;
    }
    return total;
  }

  // Query fees with optional filters (status, type, batchId)
  Future<List<FeeModel>> getFilteredFees({
    FeePaymentStatus? status,
    FeeType? type,
    String? batchId,
  }) async {
    Query query = _firestore.collection(FirebasePaths.fees);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    if (batchId != null) {
      query = query.where('batchId', isEqualTo: batchId);
    }

    final snap = await query.get();
    return snap.docs.map((doc) => FeeModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
