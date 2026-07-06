import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String userId;
  final String? userName;
  final String? description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const ActivityLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.userId,
    this.userName,
    this.description,
    this.metadata = const {},
    required this.timestamp,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String?,
      description: json['description'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      timestamp: _parseDateTime(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'userId': userId,
      'userName': userName,
      'description': description,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  ActivityLogModel copyWith({
    String? id,
    String? action,
    String? entityType,
    String? entityId,
    String? userId,
    String? userName,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return ActivityLogModel(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
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
      other is ActivityLogModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ActivityLogModel(id: $id, action: $action, entityType: $entityType)';
}
