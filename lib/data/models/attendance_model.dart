import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus {
  present,
  absent,
  leave,
  late;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

class AttendanceModel {
  final String id;
  final String studentId;
  final String batchId;
  final DateTime date;
  final AttendanceStatus status;
  final String? markedBy;
  final DateTime markedAt;
  final String? note;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.date,
    required this.status,
    this.markedBy,
    required this.markedAt,
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      date: _parseDateTime(json['date']),
      status: AttendanceStatus.fromString(
          json['status'] as String? ?? 'absent'),
      markedBy: json['markedBy'] as String?,
      markedAt: _parseDateTime(json['markedAt']),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'batchId': batchId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'markedBy': markedBy,
      'markedAt': Timestamp.fromDate(markedAt),
      'note': note,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? studentId,
    String? batchId,
    DateTime? date,
    AttendanceStatus? status,
    String? markedBy,
    DateTime? markedAt,
    String? note,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      date: date ?? this.date,
      status: status ?? this.status,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
      note: note ?? this.note,
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
      other is AttendanceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AttendanceModel(id: $id, studentId: $studentId, status: ${status.name})';
}
