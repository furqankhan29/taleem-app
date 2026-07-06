import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taleem/app/routes/app_routes.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/errors/error_handler.dart';
import 'package:taleem/core/utils/helpers.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/core/services/push_notification_service.dart';
import 'package:taleem/data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind current auth state
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      currentUser.value = null;
      isLoggedIn.value = false;
    } else {
      await _fetchUserProfile(user.uid);
      isLoggedIn.value = true;
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(FirebasePaths.users).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        currentUser.value = UserModel.fromJson(doc.data()!);
      } else {
        // Create a default profile if firestore document doesn't exist yet
        final user = _auth.currentUser;
        if (user != null) {
          final newUser = UserModel(
            id: uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'New User',
            photoUrl: user.photoURL,
            role: UserRole.student, // default role
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            fcmTokens: [],
          );
          await _firestore.collection(FirebasePaths.users).doc(uid).set(newUser.toJson());
          currentUser.value = newUser;
        }
      }
    } catch (e) {
      Logger.error('Failed to fetch user profile from Firestore', e);
      // Fallback local user model to prevent UI crash
      final user = _auth.currentUser;
      if (user != null) {
        currentUser.value = UserModel(
          id: uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Offline User',
          role: UserRole.admin, // fallback to admin for testing when offline
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          fcmTokens: [],
        );
      }
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        if (!credential.user!.emailVerified) {
          Get.toNamed(AppRoutes.emailVerification);
          return;
        }
        
        await _fetchUserProfile(credential.user!.uid);
        Helpers.showSnackbar(
          title: 'Success',
          message: 'Welcome back, ${currentUser.value?.displayName ?? "User"}!',
        );
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Login Failed', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String email, String password, String name, UserRole role) async {
    isLoading.value = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email.trim(),
          displayName: name.trim(),
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          fcmTokens: [],
        );

        await _firestore
            .collection(FirebasePaths.users)
            .doc(credential.user!.uid)
            .set(newUser.toJson());

        currentUser.value = newUser;

        // Send email verification
        await credential.user!.sendEmailVerification();
        
        Get.toNamed(AppRoutes.emailVerification);
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Signup Failed', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return; // user cancelled the flow
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _fetchUserProfile(userCredential.user!.uid);
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Google Sign In Failed', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Helpers.showSnackbar(
        title: 'Email Sent',
        message: 'Password reset link has been sent to your email.',
      );
      Get.back();
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Error', message: appEx.message, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        await _fetchUserProfile(user.uid);
        Helpers.showSnackbar(
          title: 'Verified',
          message: 'Your email has been successfully verified.',
        );
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Helpers.showSnackbar(
          title: 'Not Verified',
          message: 'Please check your email and click the verification link.',
          isError: true,
        );
      }
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        Helpers.showSnackbar(
          title: 'Email Sent',
          message: 'Verification email has been resent.',
        );
      } catch (e) {
        final appEx = ErrorHandler.handleError(e);
        Helpers.showSnackbar(title: 'Error', message: appEx.message, isError: true);
      }
    }
  }

  Future<void> signOut() async {
    try {
      if (Get.isRegistered<PushNotificationService>()) {
        await Get.find<PushNotificationService>().deregisterDeviceForNotifications();
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
      currentUser.value = null;
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      final appEx = ErrorHandler.handleError(e);
      Helpers.showSnackbar(title: 'Logout Failed', message: appEx.message, isError: true);
    }
  }
}
