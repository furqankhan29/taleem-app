import 'package:cloud_firestore/cloud_firestore.dart';

enum AIMessageRole {
  user,
  assistant,
  system;

  static AIMessageRole fromString(String value) {
    return AIMessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AIMessageRole.assistant,
    );
  }
}

enum AIMessageType {
  text,
  richCard,
  chart,
  table;

  static AIMessageType fromString(String value) {
    return AIMessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AIMessageType.text,
    );
  }
}

class AIAttachment {
  final String name;
  final String url;
  final String type;
  final int? size;

  const AIAttachment({
    required this.name,
    required this.url,
    required this.type,
    this.size,
  });

  factory AIAttachment.fromJson(Map<String, dynamic> json) {
    return AIAttachment(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'file',
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'size': size,
    };
  }
}

class AIChatMessage {
  final String id;
  final String conversationId;
  final AIMessageRole role;
  final String content;
  final DateTime timestamp;
  final AIMessageType type;
  final Map<String, dynamic>? metadata;
  final List<AIAttachment>? attachments;
  final bool isStreaming;

  const AIChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.type = AIMessageType.text,
    this.metadata,
    this.attachments,
    this.isStreaming = false,
  });

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      role: AIMessageRole.fromString(json['role'] as String? ?? 'assistant'),
      content: json['content'] as String? ?? '',
      timestamp: _parseDateTime(json['timestamp']),
      type: AIMessageType.fromString(json['type'] as String? ?? 'text'),
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List?)
          ?.map((e) => AIAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      isStreaming: json['isStreaming'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.name,
      'metadata': metadata,
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'isStreaming': isStreaming,
    };
  }

  AIChatMessage copyWith({
    String? id,
    String? conversationId,
    AIMessageRole? role,
    String? content,
    DateTime? timestamp,
    AIMessageType? type,
    Map<String, dynamic>? metadata,
    List<AIAttachment>? attachments,
    bool? isStreaming,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      isStreaming: isStreaming ?? this.isStreaming,
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
      other is AIChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AIChatMessage(id: $id, role: ${role.name})';
}
