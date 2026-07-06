import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/core/constants/firebase_paths.dart';
import 'package:taleem/data/models/ai_chat_message_model.dart';
import 'package:taleem/data/models/ai_conversation_model.dart';
import 'package:taleem/data/providers/firebase_provider.dart';

class AIRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseProvider firebaseProvider;

  AIRepository({required this.firebaseProvider});

  Future<void> createConversation(AIConversation conversation) async {
    await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(conversation.id)
        .set(conversation.toJson());
  }

  Future<void> updateConversation(AIConversation conversation) async {
    await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(conversation.id)
        .update(conversation.toJson());
  }

  Future<void> deleteConversation(String id) async {
    await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(id)
        .delete();
  }

  Future<void> togglePinConversation(String id, bool isPinned) async {
    await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(id)
        .update({'isPinned': isPinned});
  }

  Stream<List<AIConversation>> streamConversations(String userId) {
    return _firestore
        .collection(FirebasePaths.aiConversations)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AIConversation.fromJson(doc.data()))
            .toList());
  }

  Future<AIConversation?> getConversation(String id) async {
    final doc = await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(id)
        .get();
    if (doc.exists && doc.data() != null) {
      return AIConversation.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> saveMessage(AIChatMessage message) async {
    await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(message.conversationId)
        .collection(FirebasePaths.aiMessages)
        .doc(message.id)
        .set(message.toJson());
  }

  Stream<List<AIChatMessage>> streamMessages(String conversationId) {
    return _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(conversationId)
        .collection(FirebasePaths.aiMessages)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AIChatMessage.fromJson(doc.data()))
            .toList());
  }

  Future<List<AIChatMessage>> getMessages(String conversationId) async {
    final snap = await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(conversationId)
        .collection(FirebasePaths.aiMessages)
        .orderBy('timestamp', descending: false)
        .get();
    return snap.docs
        .map((doc) => AIChatMessage.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    await _firestore
        .collection(FirebasePaths.aiConversations)
        .doc(conversationId)
        .collection(FirebasePaths.aiMessages)
        .doc(messageId)
        .delete();
  }

  Future<List<AIConversation>> searchConversations({
    required String userId,
    required String query,
  }) async {
    final snap = await _firestore
        .collection(FirebasePaths.aiConversations)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();

    final all = snap.docs
        .map((doc) => AIConversation.fromJson(doc.data()))
        .toList();

    if (query.trim().isEmpty) return all;

    final lower = query.toLowerCase();
    return all.where((c) =>
        c.title.toLowerCase().contains(lower) ||
        (c.lastMessagePreview?.toLowerCase().contains(lower) ?? false) ||
        c.tags.any((t) => t.toLowerCase().contains(lower))
    ).toList();
  }
}
