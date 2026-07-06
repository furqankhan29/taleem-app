import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/services/whatsapp_service.dart';
import 'package:taleem/core/utils/formatters.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/student_model.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/models/whatsapp_reminder_model.dart';
import 'package:taleem/data/repositories/whatsapp_reminder_repository.dart';

class WhatsappController extends GetxController {
  final WhatsappReminderRepository _reminderRepository = Get.find<WhatsappReminderRepository>();
  final WhatsAppService _whatsappService = Get.find<WhatsAppService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<WhatsappReminderModel> deliveryLogs = <WhatsappReminderModel>[].obs;
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, String>> templates = <Map<String, String>>[].obs;

  final RxBool isLoadingLogs = false.obs;
  final RxBool isLoadingSuggestions = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTemplates();
    loadSuggestions();
    loadDeliveryLogs();
  }

  void _loadTemplates() {
    templates.assignAll([
      {
        'id': 'absent_alert',
        'name': 'Absent Alert Template',
        'body': 'Dear Parent, your child {{studentName}} was marked absent today in class. Please provide a reason at your earliest convenience. Thank you, Taleem System.'
      },
      {
        'id': 'fee_due',
        'name': 'Fee Due Reminder',
        'body': 'Dear Parent, this is a reminder that the tuition fee of {{feeAmount}} for {{studentName}} was due on {{dueDate}}. Please clear it at your earliest. Thank you, Taleem System.'
      },
      {
        'id': 'general_announcement',
        'name': 'General Announcement',
        'body': 'Dear Parents, please be informed that classes will remain closed tomorrow due to the scheduled public holiday. Classes will resume normally on the following day. Thank you.'
      }
    ]);
  }

  Future<void> loadDeliveryLogs() async {
    isLoadingLogs.value = true;
    try {
      final logs = await _reminderRepository.getDeliveryLogs();
      deliveryLogs.assignAll(logs);
    } catch (e) {
      Logger.error('Failed to load delivery logs', e);
    } finally {
      isLoadingLogs.value = false;
    }
  }

  Future<void> loadSuggestions() async {
    isLoadingSuggestions.value = true;
    suggestions.clear();

    try {
      // 1. Fetch pending absence records we generated in Phase 3
      final absenceSnap = await _firestore
          .collection('absences')
          .where('reminderStatus', isEqualTo: 'pending')
          .get();

      for (final doc in absenceSnap.docs) {
        final data = doc.data();
        final studentName = data['studentName'] as String;
        final date = (data['date'] as Timestamp).toDate();

        // Retrieve Parent's phone number
        String phone = '';
        final parentId = data['parentId'] as String?;
        if (parentId != null && parentId.isNotEmpty) {
          final parentDoc = await _firestore.collection(FirebasePaths.parents).doc(parentId).get();
          if (parentDoc.exists && parentDoc.data() != null) {
            phone = parentDoc.data()?['phone'] as String? ?? '';
          }
        }

        // Fill templates
        var message = templates.firstWhere((t) => t['id'] == 'absent_alert')['body']!;
        message = message.replaceAll('{{studentName}}', studentName);

        suggestions.add({
          'id': doc.id,
          'type': 'absence',
          'studentName': studentName,
          'phone': phone.isEmpty ? 'N/A' : phone,
          'message': message,
          'details': 'Absent on ${Formatters.formatDate(date)}',
          'docRef': doc.reference,
        });
      }

      // 2. Fetch overdue fee suggestions
      final feeSnap = await _firestore
          .collection(FirebasePaths.fees)
          .where('status', whereIn: [FeePaymentStatus.pending.name, FeePaymentStatus.overdue.name])
          .get();

      for (final doc in feeSnap.docs) {
        final fee = FeeModel.fromJson(doc.data());
        if (fee.dueDate.isBefore(DateTime.now())) {
          // Fetch student name and parent details
          final studentDoc = await _firestore.collection(FirebasePaths.students).doc(fee.studentId).get();
          if (!studentDoc.exists) continue;
          final student = StudentModel.fromJson(studentDoc.data()!);

          String phone = '';
          if (student.parentId != null && student.parentId!.isNotEmpty) {
            final parentDoc = await _firestore.collection(FirebasePaths.parents).doc(student.parentId!).get();
            if (parentDoc.exists && parentDoc.data() != null) {
              phone = parentDoc.data()?['phone'] as String? ?? '';
            }
          }

          var message = templates.firstWhere((t) => t['id'] == 'fee_due')['body']!;
          message = message
              .replaceAll('{{studentName}}', student.name)
              .replaceAll('{{feeAmount}}', '\$${formatPercentageOrAmount(fee.balanceDue)}')
              .replaceAll('{{dueDate}}', Formatters.formatDate(fee.dueDate));

          suggestions.add({
            'id': doc.id,
            'type': 'fee',
            'studentName': student.name,
            'phone': phone.isEmpty ? 'N/A' : phone,
            'message': message,
            'details': 'Overdue fee: \$${fee.balanceDue}',
            'docRef': doc.reference,
          });
        }
      }
    } catch (e) {
      Logger.error('Failed to load suggestions', e);
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  String formatPercentageOrAmount(double value) {
    return value.toStringAsFixed(1);
  }

  Future<void> sendWhatsAppMessage(Map<String, dynamic> suggestion) async {
    final phone = suggestion['phone'] as String;
    final message = suggestion['message'] as String;

    if (phone == 'N/A' || phone.isEmpty) {
      Helpers.showSnackbar(title: 'Phone Missing', message: 'No registered parent phone number for this student.', isError: true);
      return;
    }

    Helpers.showLoadingDialog('Opening WhatsApp...');
    try {
      final success = await _whatsappService.sendMessage(phone: phone, message: message);
      Helpers.hideLoadingDialog();

      if (success) {
        // Mark as sent in Firestore
        final docRef = suggestion['docRef'] as DocumentReference?;
        if (docRef != null) {
          final collectionPath = docRef.parent.id;
          if (collectionPath == 'absences') {
            await docRef.update({'reminderStatus': 'sent'});
          }
        }

        // Add to reminder delivery logs collection
        final logId = 'rem_${DateTime.now().millisecondsSinceEpoch}';
        final newLog = WhatsappReminderModel(
          id: logId,
          recipientPhone: phone,
          recipientName: suggestion['studentName'],
          message: message,
          scheduledAt: DateTime.now(),
          sentAt: DateTime.now(),
          status: WhatsappReminderStatus.sent,
          type: suggestion['type'] == 'absence' ? WhatsappReminderType.attendance : WhatsappReminderType.fee,
        );

        await _reminderRepository.create(newLog);

        // Reload lists
        await loadSuggestions();
        await loadDeliveryLogs();

        Helpers.showSnackbar(title: 'Success', message: 'WhatsApp message triggered successfully');
      } else {
        Helpers.showSnackbar(title: 'Launcher Error', message: 'Could not open WhatsApp. Ensure it is installed on this device.', isError: true);
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Failed to Send', message: appEx.message, isError: true);
    }
  }
}
