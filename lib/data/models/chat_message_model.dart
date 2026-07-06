import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatMessageRole {
  user,
  assistant;

  static ChatMessageRole fromString(String value) {
    return ChatMessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatMessageRole.user,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String userId;
  final String content;
  final ChatMessageRole role;
  final Map<String, dynamic>? richData;
  final DateTime timestamp;
  final List<String>? suggestions;

  const ChatMessageModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.role,
    this.richData,
    required this.timestamp,
    this.suggestions,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      role: ChatMessageRole.fromString(json['role'] as String? ?? 'user'),
      richData: json['richData'] != null
          ? Map<String, dynamic>.from(json['richData'] as Map)
          : null,
      timestamp: _parseDateTime(json['timestamp']),
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'role': role.name,
      'richData': richData,
      'timestamp': Timestamp.fromDate(timestamp),
      'suggestions': suggestions,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? userId,
    String? content,
    ChatMessageRole? role,
    Map<String, dynamic>? richData,
    DateTime? timestamp,
    List<String>? suggestions,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      role: role ?? this.role,
      richData: richData ?? this.richData,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  bool get isUser => role == ChatMessageRole.user;

  bool get isAssistant => role == ChatMessageRole.assistant;

  bool get hasSuggestions =>
      suggestions != null && suggestions!.isNotEmpty;

  bool get hasRichData => richData != null && richData!.isNotEmpty;

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ChatMessageModel(id: $id, role: ${role.name}, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
}
