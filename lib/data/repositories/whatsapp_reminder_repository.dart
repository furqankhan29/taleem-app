import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/whatsapp_reminder_model.dart';
import 'package:taleem/data/repositories/base_repository.dart';

class WhatsappReminderRepository extends BaseRepository<WhatsappReminderModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WhatsappReminderRepository({required super.firebaseProvider})
      : super(collectionPath: FirebasePaths.whatsappReminders);

  @override
  WhatsappReminderModel fromJson(Map<String, dynamic> json) => WhatsappReminderModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(WhatsappReminderModel model) => model.toJson();

  @override
  String getModelId(WhatsappReminderModel model) => model.id;

  // Retrieve delivery logs / history sorted by date
  Future<List<WhatsappReminderModel>> getDeliveryLogs() async {
    final snap = await _firestore
        .collection(FirebasePaths.whatsappReminders)
        .orderBy('scheduledAt', descending: true)
        .get();

    return snap.docs.map((doc) => WhatsappReminderModel.fromJson(doc.data())).toList();
  }

  // Retrieve reminders filtered by type
  Future<List<WhatsappReminderModel>> getRemindersByType(WhatsappReminderType type) async {
    final snap = await _firestore
        .collection(FirebasePaths.whatsappReminders)
        .where('type', isEqualTo: type.name)
        .orderBy('scheduledAt', descending: true)
        .get();

    return snap.docs.map((doc) => WhatsappReminderModel.fromJson(doc.data())).toList();
  }
}
