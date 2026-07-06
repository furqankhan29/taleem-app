import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/services/cache_service.dart';
import 'package:taleem/core/services/storage_service.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/user_model.dart';
import 'package:taleem/modules/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final CacheService _cache = Get.find<CacheService>();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool loading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Bind to AuthController's reactive currentUser state
    user.value = _authController.currentUser.value;
    _authController.currentUser.listen((val) {
      user.value = val;
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    loading.value = true;
    error.value = null;
    try {
      final current = user.value;
      if (current == null) return;
      final updated = current.copyWith(
        displayName: displayName,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
      );

      // Save user updates to Cloud Firestore
      await FirebaseFirestore.instance
          .collection(FirebasePaths.users)
          .doc(current.id)
          .set(updated.toJson(), SetOptions(merge: true));

      // Synchronize in-memory auth states
      _authController.currentUser.value = updated;
      user.value = updated;

      // Cache locally for offline fast bootstrapping
      await _cache.write('current_user', updated.toJson());
      
      Logger.success('User profile updated successfully');
    } catch (e) {
      error.value = e.toString();
      Logger.error('Failed to update user profile in Firestore', e);
      rethrow;
    } finally {
      loading.value = false;
    }
  }

  Future<void> uploadPhoto() async {
    final imagePicker = ImagePicker();
    try {
      final image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;

      loading.value = true;
      Helpers.showLoadingDialog('Uploading Profile Picture...');

      final storageService = Get.find<StorageService>();
      final path = StorageService.getProfileImagePath(user.value!.id);

      final downloadUrl = await storageService.uploadFile(
        file: File(image.path),
        path: path,
      );

      await updateProfile(photoUrl: downloadUrl);
      Helpers.hideLoadingDialog();
      Helpers.showSnackbar(title: 'Success', message: 'Profile photo updated successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      error.value = e.toString();
      Helpers.showSnackbar(title: 'Upload Failed', message: error.value!, isError: true);
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _authController.signOut();
  }
}

