import 'package:cloud_firestore/cloud_firestore.dart';

enum BatchSchedule {
  morning,
  afternoon,
  evening;

  static BatchSchedule fromString(String value) {
    return BatchSchedule.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BatchSchedule.morning,
    );
  }
}

enum BatchStatus {
  active,
  inactive,
  completed;

  static BatchStatus fromString(String value) {
    return BatchStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BatchStatus.active,
    );
  }
}

class BatchModel {
  final String id;
  final String name;
  final String code;
  final BatchSchedule schedule;
  final String? teacherId;
  final String? subjectId;
  final List<String> studentIds;
  final int maxCapacity;
  final String? startTime;
  final String? endTime;
  final List<String> days;
  final String? room;
  final BatchStatus status;
  final DateTime createdAt;

  const BatchModel({
    required this.id,
    required this.name,
    required this.code,
    this.schedule = BatchSchedule.morning,
    this.teacherId,
    this.subjectId,
    this.studentIds = const [],
    this.maxCapacity = 30,
    this.startTime,
    this.endTime,
    this.days = const [],
    this.room,
    this.status = BatchStatus.active,
    required this.createdAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      schedule: BatchSchedule.fromString(
          json['schedule'] as String? ?? 'morning'),
      teacherId: json['teacherId'] as String?,
      subjectId: json['subjectId'] as String?,
      studentIds: List<String>.from(json['studentIds'] as List? ?? []),
      maxCapacity: json['maxCapacity'] as int? ?? 30,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      days: List<String>.from(json['days'] as List? ?? []),
      room: json['room'] as String?,
      status: BatchStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'schedule': schedule.name,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'studentIds': studentIds,
      'maxCapacity': maxCapacity,
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
      'room': room,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BatchModel copyWith({
    String? id,
    String? name,
    String? code,
    BatchSchedule? schedule,
    String? teacherId,
    String? subjectId,
    List<String>? studentIds,
    int? maxCapacity,
    String? startTime,
    String? endTime,
    List<String>? days,
    String? room,
    BatchStatus? status,
    DateTime? createdAt,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      schedule: schedule ?? this.schedule,
      teacherId: teacherId ?? this.teacherId,
      subjectId: subjectId ?? this.subjectId,
      studentIds: studentIds ?? this.studentIds,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      days: days ?? this.days,
      room: room ?? this.room,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get currentStrength => studentIds.length;

  bool get isFull => studentIds.length >= maxCapacity;

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BatchModel(id: $id, name: $name, code: $code)';
}
