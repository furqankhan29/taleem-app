import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/core/utils/logger.dart';
import 'package:taleem/data/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final Rxn<UserRole> currentRole = Rxn<UserRole>();
  final RxBool isLoggedIn = false.obs;
  final RxBool sessionValid = true.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _clearState();
    } else {
      await getCurrentUser();
      isLoggedIn.value = currentUser.value != null;
    }
  }

  void _clearState() {
    currentUser.value = null;
    currentRole.value = null;
    isLoggedIn.value = false;
    sessionValid.value = false;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _firestore.collection(FirebasePaths.users).doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User profile not found',
        );
      }

      final user = UserModel.fromJson(doc.data()!);

      if (!user.isActive) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'This account has been deactivated',
        );
      }

      currentUser.value = user;
      currentRole.value = user.role;
      isLoggedIn.value = true;
      sessionValid.value = true;

      await _firestore.collection(FirebasePaths.users).doc(uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });

      Logger.success('User signed in: ${user.email}');
      return user;
    } catch (e) {
      Logger.error('Sign in failed', e);
      rethrow;
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final now = DateTime.now();

      final user = UserModel(
        id: uid,
        email: email.trim(),
        displayName: name.trim(),
        role: role,
        createdAt: now,
        lastLoginAt: now,
        fcmTokens: [],
      );

      await _firestore.collection(FirebasePaths.users).doc(uid).set(user.toJson());

      currentUser.value = user;
      currentRole.value = role;
      isLoggedIn.value = true;
      sessionValid.value = true;

      Logger.success('User signed up: ${user.email}');
      return user;
    } catch (e) {
      Logger.error('Sign up failed', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _clearState();
      Logger.info('User signed out');
    } catch (e) {
      Logger.error('Sign out failed', e);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _clearState();
        return null;
      }

      final doc = await _firestore.collection(FirebasePaths.users).doc(user.uid).get();

      if (!doc.exists || doc.data() == null) {
        _clearState();
        return null;
      }

      final userModel = UserModel.fromJson(doc.data()!);
      currentUser.value = userModel;
      currentRole.value = userModel.role;
      isLoggedIn.value = true;
      sessionValid.value = userModel.isActive;

      return userModel;
    } catch (e) {
      Logger.error('Failed to get current user', e);
      return currentUser.value;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.getIdToken(true);
      Logger.info('Token refreshed successfully');
      return true;
    } catch (e) {
      Logger.error('Token refresh failed', e);
      sessionValid.value = false;
      return false;
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(FirebasePaths.users).doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });

      Logger.info('FCM token updated');
    } catch (e) {
      Logger.error('Failed to update FCM token', e);
    }
  }

  Future<void> removeFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(FirebasePaths.users).doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });

      Logger.info('FCM token removed');
    } catch (e) {
      Logger.error('Failed to remove FCM token', e);
    }
  }

  Future<bool> checkSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        sessionValid.value = false;
        return false;
      }

      final token = await user.getIdToken();
      if (token == null) {
        sessionValid.value = false;
        return false;
      }

      final doc = await _firestore.collection(FirebasePaths.users).doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        sessionValid.value = false;
        return false;
      }

      final userModel = UserModel.fromJson(doc.data()!);
      if (!userModel.isActive) {
        sessionValid.value = false;
        return false;
      }

      currentUser.value = userModel;
      currentRole.value = userModel.role;
      sessionValid.value = true;
      return true;
    } catch (e) {
      Logger.error('Session check failed', e);
      sessionValid.value = false;
      return false;
    }
  }
}
