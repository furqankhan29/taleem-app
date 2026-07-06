import 'package:cloud_firestore/cloud_firestore.dart';

class AIConversation {
  final String id;
  final String title;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool isPinned;
  final List<String> tags;
  final String? lastMessagePreview;

  const AIConversation({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.isPinned = false,
    this.tags = const [],
    this.lastMessagePreview,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      messageCount: json['messageCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      lastMessagePreview: json['lastMessagePreview'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'messageCount': messageCount,
      'isPinned': isPinned,
      'tags': tags,
      'lastMessagePreview': lastMessagePreview,
    };
  }

  AIConversation copyWith({
    String? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    bool? isPinned,
    List<String>? tags,
    String? lastMessagePreview,
  }) {
    return AIConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIConversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AIConversation(id: $id, title: $title)';
}
