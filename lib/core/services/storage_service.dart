import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:taleem/core/utils/logger.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Centralized upload method with retry logic and progress callbacks
  Future<String> uploadFile({
    required File file,
    required String path,
    SettableMetadata? metadata,
    Function(double progress)? onProgress,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      attempts++;
      try {
        final ref = _storage.ref().child(path);
        final uploadTask = ref.putFile(file, metadata);

        // Listen to progress updates
        final subscription = uploadTask.snapshotEvents.listen((event) {
          final total = event.totalBytes;
          final transferred = event.bytesTransferred;
          if (total > 0 && onProgress != null) {
            final progress = transferred / total;
            onProgress(progress);
          }
        });

        // Wait for upload task completion
        final snapshot = await uploadTask;
        await subscription.cancel();

        final downloadUrl = await snapshot.ref.getDownloadURL();
        Logger.success('Uploaded file to $path (Attempt $attempts/$maxRetries)');
        return downloadUrl;
      } catch (e) {
        Logger.error('Upload attempt $attempts/$maxRetries failed for path $path', e);
        if (attempts >= maxRetries) {
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    throw FirebaseException(
      plugin: 'firebase_storage',
      message: 'Failed to upload file after $maxRetries attempts',
    );
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      Logger.info('Deleted file at path: $path');
    } catch (e) {
      Logger.error('Failed to delete file at path: $path', e);
      rethrow;
    }
  }

  // Predefined paths helper
  static String getProfileImagePath(String userId) => 'profile_images/$userId/profile.jpg';
  static String getStudentPhotoPath(String studentId) => 'student_photos/$studentId/photo.jpg';
  static String getTeacherPhotoPath(String teacherId) => 'teacher_photos/$teacherId/photo.jpg';
  static String getHomeworkAttachmentPath(String batchId, String homeworkId, String fileName) =>
      'homework_attachments/$batchId/$homeworkId/$fileName';
  static String getFeeReceiptPath(String feeId, String fileName) => 'fee_receipts/$feeId/$fileName';
  static String getReportExportPath(String reportId, String fileName) => 'report_exports/$reportId/$fileName';
}
