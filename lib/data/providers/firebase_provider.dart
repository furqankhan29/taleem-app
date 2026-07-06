import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/errors/error_handler.dart';

class FirebaseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseProvider();

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String id,
  ) async {
    try {
      return await _firestore.collection(collection).doc(id).get();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection,
  ) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  Future<void> addDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(id).set(data);
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  Future<void> deleteDocument(
    String collection,
    String id,
  ) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collection,
    String id,
  ) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection,
  ) {
    return _firestore.collection(collection).snapshots();
  }
}
