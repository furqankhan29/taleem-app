import 'package:cloud_firestore/cloud_firestore.dart';

enum HomeworkStatus {
  active,
  completed,
  overdue;

  static HomeworkStatus fromString(String value) {
    return HomeworkStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HomeworkStatus.active,
    );
  }
}

class HomeworkModel {
  final String id;
  final String batchId;
  final String subjectId;
  final String teacherId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final List<String> attachments;
  final HomeworkStatus status;
  final DateTime createdAt;

  const HomeworkModel({
    required this.id,
    required this.batchId,
    required this.subjectId,
    required this.teacherId,
    required this.title,
    this.description,
    required this.dueDate,
    this.attachments = const [],
    this.status = HomeworkStatus.active,
    required this.createdAt,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: _parseDateTime(json['dueDate']),
      attachments: List<String>.from(json['attachments'] as List? ?? []),
      status:
          HomeworkStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'attachments': attachments,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  HomeworkModel copyWith({
    String? id,
    String? batchId,
    String? subjectId,
    String? teacherId,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? attachments,
    HomeworkStatus? status,
    DateTime? createdAt,
  }) {
    return HomeworkModel(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue =>
      status != HomeworkStatus.completed && DateTime.now().isAfter(dueDate);

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeworkModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HomeworkModel(id: $id, title: $title)';
}
