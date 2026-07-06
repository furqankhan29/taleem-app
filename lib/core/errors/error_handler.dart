import 'package:firebase_auth/firebase_auth.dart';
import 'package:taleem/core/errors/app_exceptions.dart';
import 'package:taleem/core/utils/logger.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    Logger.error('An error occurred', error, stackTrace);

    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return FirestoreException(
        error.message ?? 'A database error occurred',
        error.code,
      );
    } else if (error is AppException) {
      return error;
    }

    return AppException(error.toString());
  }

  static AppException _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return const AuthException('No user found for that email.', 'user-not-found');
      case 'wrong-password':
        return const AuthException('Wrong password provided.', 'wrong-password');
      case 'email-already-in-use':
        return const AuthException('The email account already exists.', 'email-already-in-use');
      case 'invalid-email':
        return const AuthException('The email address is invalid.', 'invalid-email');
      case 'weak-password':
        return const AuthException('The password provided is too weak.', 'weak-password');
      case 'user-disabled':
        return const AuthException('This user account has been disabled.', 'user-disabled');
      case 'operation-not-allowed':
        return const AuthException('Operation not allowed.', 'operation-not-allowed');
      case 'network-request-failed':
        return const NetworkException('Network request failed. Please check your internet connection.', 'network-request-failed');
      default:
        return AuthException(error.message ?? 'Authentication failed', error.code);
    }
  }
}
