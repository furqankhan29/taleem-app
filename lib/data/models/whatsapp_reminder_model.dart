import 'package:cloud_firestore/cloud_firestore.dart';

enum WhatsappReminderStatus {
  pending,
  sent,
  failed,
  cancelled;

  static WhatsappReminderStatus fromString(String value) {
    return WhatsappReminderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WhatsappReminderStatus.pending,
    );
  }
}

enum WhatsappReminderType {
  fee,
  attendance,
  general;

  static WhatsappReminderType fromString(String value) {
    return WhatsappReminderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WhatsappReminderType.general,
    );
  }
}

class WhatsappReminderModel {
  final String id;
  final String? templateId;
  final String recipientPhone;
  final String? recipientName;
  final String message;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final WhatsappReminderStatus status;
  final WhatsappReminderType type;
  final String? createdBy;

  const WhatsappReminderModel({
    required this.id,
    this.templateId,
    required this.recipientPhone,
    this.recipientName,
    required this.message,
    required this.scheduledAt,
    this.sentAt,
    this.status = WhatsappReminderStatus.pending,
    this.type = WhatsappReminderType.general,
    this.createdBy,
  });

  factory WhatsappReminderModel.fromJson(Map<String, dynamic> json) {
    return WhatsappReminderModel(
      id: json['id'] as String? ?? '',
      templateId: json['templateId'] as String?,
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientName: json['recipientName'] as String?,
      message: json['message'] as String? ?? '',
      scheduledAt: _parseDateTime(json['scheduledAt']),
      sentAt: _parseDateTimeNullable(json['sentAt']),
      status: WhatsappReminderStatus.fromString(
          json['status'] as String? ?? 'pending'),
      type: WhatsappReminderType.fromString(
          json['type'] as String? ?? 'general'),
      createdBy: json['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'recipientPhone': recipientPhone,
      'recipientName': recipientName,
      'message': message,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'status': status.name,
      'type': type.name,
      'createdBy': createdBy,
    };
  }

  WhatsappReminderModel copyWith({
    String? id,
    String? templateId,
    String? recipientPhone,
    String? recipientName,
    String? message,
    DateTime? scheduledAt,
    DateTime? sentAt,
    WhatsappReminderStatus? status,
    WhatsappReminderType? type,
    String? createdBy,
  }) {
    return WhatsappReminderModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      message: message ?? this.message,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isPending => status == WhatsappReminderStatus.pending;

  bool get isSent => status == WhatsappReminderStatus.sent;

  bool get isFailed => status == WhatsappReminderStatus.failed;

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhatsappReminderModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WhatsappReminderModel(id: $id, phone: $recipientPhone, status: ${status.name})';
}
