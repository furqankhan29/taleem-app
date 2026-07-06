import 'package:taleem/data/providers/firebase_provider.dart';

abstract class BaseRepository<T> {
  final FirebaseProvider firebaseProvider;
  final String collectionPath;

  BaseRepository({
    required this.firebaseProvider,
    required this.collectionPath,
  });

  // Mapper function to convert JSON map to type T
  T fromJson(Map<String, dynamic> json);

  // Mapper function to convert type T to JSON map
  Map<String, dynamic> toJson(T model);

  // Get the ID of the model
  String getModelId(T model);

  Future<T?> getById(String id) async {
    final doc = await firebaseProvider.getDocument(collectionPath, id);
    if (doc.exists && doc.data() != null) {
      return fromJson(doc.data()!);
    }
    return null;
  }

  Future<List<T>> getAll() async {
    final snap = await firebaseProvider.getCollection(collectionPath);
    return snap.docs
        .map((doc) => fromJson(doc.data()))
        .toList();
  }

  Future<void> create(T model) async {
    final id = getModelId(model);
    await firebaseProvider.addDocument(collectionPath, id, toJson(model));
  }

  Future<void> update(T model) async {
    final id = getModelId(model);
    await firebaseProvider.updateDocument(collectionPath, id, toJson(model));
  }

  Future<void> delete(String id) async {
    await firebaseProvider.deleteDocument(collectionPath, id);
  }

  Stream<T?> streamById(String id) {
    return firebaseProvider.streamDocument(collectionPath, id).map((doc) {
      if (doc.exists && doc.data() != null) {
        return fromJson(doc.data()!);
      }
      return null;
    });
  }

  Stream<List<T>> streamAll() {
    return firebaseProvider.streamCollection(collectionPath).map((snap) {
      return snap.docs.map((doc) => fromJson(doc.data())).toList();
    });
  }
}
