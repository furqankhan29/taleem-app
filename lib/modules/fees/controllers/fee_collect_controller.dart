import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/network/connectivity_service.dart';
import 'package:taleem/core/services/sync_service.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/data/models/fee_model.dart';
import 'package:taleem/data/models/student_model.dart';

class FeeCollectController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final SyncService _syncService = Get.find<SyncService>();

  final Rxn<FeeModel> selectedFee = Rxn<FeeModel>();
  final Rxn<StudentModel> selectedStudent = Rxn<StudentModel>();

  // Payment Form Parameters
  final RxDouble payAmount = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxString paymentMethod = 'Cash'.obs;
  final RxString transactionId = ''.obs;
  final RxString note = ''.obs;
  
  final Rxn<File> selectedReceiptSlip = Rxn<File>();
  final RxBool isUploading = false.obs;
  final RxBool isSaving = false.obs;

  final List<String> paymentMethods = ['Cash', 'Bank Transfer', 'JazzCash', 'Easypaisa', 'Stripe'];

  @override
  void onInit() {
    super.onInit();
    
    // If a fee model argument is passed, initialize defaults
    if (Get.arguments is FeeModel) {
      final fee = Get.arguments as FeeModel;
      selectedFee.value = fee;
      payAmount.value = fee.balanceDue;
      _loadStudent(fee.studentId);
    }
  }

  Future<void> _loadStudent(String studentId) async {
    try {
      final snap = await _firestore.collection(FirebasePaths.students).doc(studentId).get();
      if (snap.exists && snap.data() != null) {
        selectedStudent.value = StudentModel.fromJson(snap.data()!);
      }
    } catch (_) {}
  }

  Future<void> pickReceiptSlip(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        selectedReceiptSlip.value = File(picked.path);
      }
    } catch (e) {
      Helpers.showSnackbar(title: 'Image Selection Failed', message: e.toString(), isError: true);
    }
  }

  Future<void> collectPayment() async {
    if (selectedFee.value == null) {
      Helpers.showSnackbar(title: 'Missing Fee Record', message: 'Please select a fee record first', isError: true);
      return;
    }

    if (payAmount.value <= 0) {
      Helpers.showSnackbar(title: 'Invalid Amount', message: 'Payment amount must be greater than zero', isError: true);
      return;
    }

    final fee = selectedFee.value!;
    if (payAmount.value > fee.balanceDue) {
      Helpers.showSnackbar(
        title: 'Excess Amount', 
        message: 'Payment amount (\$${payAmount.value}) exceeds balance due (\$${fee.balanceDue})', 
        isError: true,
      );
      return;
    }

    isSaving.value = true;
    Helpers.showLoadingDialog('Recording Payment...');

    String? receiptUrl;

    try {
      // 1. Upload receipt slip to storage if picked and online
      if (selectedReceiptSlip.value != null && _connectivity.isConnected.value) {
        isUploading.value = true;
        final ref = _storage.ref().child('fees/receipts/${fee.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(selectedReceiptSlip.value!);
        receiptUrl = await ref.getDownloadURL();
        isUploading.value = false;
      }

      // 2. Build payment object
      final newPayment = FeePayment(
        amount: payAmount.value,
        date: DateTime.now(),
        method: paymentMethod.value,
        receiptUrl: receiptUrl,
        transactionId: transactionId.value.isEmpty ? null : transactionId.value,
      );

      // Add to list of existing payments
      final updatedPayments = List<FeePayment>.from(fee.payments)..add(newPayment);

      // Compute status based on new balance
      final newPaidTotal = fee.totalPaid + payAmount.value;
      final newStatus = newPaidTotal >= fee.amount ? FeePaymentStatus.paid : FeePaymentStatus.partial;

      final updatedFee = fee.copyWith(
        payments: updatedPayments,
        status: newStatus,
      );

      if (_connectivity.isConnected.value) {
        // Run Firestore Transaction
        await _firestore.runTransaction((transaction) async {
          final docRef = _firestore.collection(FirebasePaths.fees).doc(fee.id);
          transaction.set(docRef, updatedFee.toJson(), SetOptions(merge: true));

          // Log payment activity on student's timeline
          final studentRef = _firestore.collection(FirebasePaths.students).doc(fee.studentId);
          // Pre-fetch student document
          final studentDoc = await transaction.get(studentRef);
          if (studentDoc.exists) {
            final oldStats = studentDoc.data()?['studentStats'] as Map<String, dynamic>? ?? {};
            final newStats = Map<String, dynamic>.from(oldStats);
            
            if (newStatus == FeePaymentStatus.paid) {
              newStats['feeStatus'] = 'Cleared';
            } else {
              newStats['feeStatus'] = 'Partial';
            }

            // Update student's fee ledger properties
            transaction.update(studentRef, {
              'studentStats': newStats,
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });
          }
        });

        Helpers.hideLoadingDialog();
        
        // Navigate to receipt view passing the updated Fee model and the new payment slip details
        Get.offAndToNamed('/fees/receipt', arguments: {
          'fee': updatedFee,
          'payment': newPayment,
          'student': selectedStudent.value,
        });

        Helpers.showSnackbar(title: 'Payment Recorded', message: 'Successfully collected \$${payAmount.value}');
      } else {
        // Queue operation offline
        await _syncService.queueOperation(
          collection: FirebasePaths.fees,
          id: fee.id,
          action: 'update',
          data: updatedFee.toJson(),
        );

        Helpers.hideLoadingDialog();
        Get.back();
        Helpers.showSnackbar(
          title: 'Offline Recorded', 
          message: 'Payment saved locally. Changes will sync to server when connection is restored.',
        );
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Payment Failed', message: appEx.message, isError: true);
    } finally {
      isSaving.value = false;
    }
  }
}
