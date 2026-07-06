import 'package:cloud_firestore/cloud_firestore.dart';

enum ExamStatus {
  scheduled,
  ongoing,
  completed,
  cancelled;

  static ExamStatus fromString(String value) {
    return ExamStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExamStatus.scheduled,
    );
  }
}

class ExamResult {
  final String studentId;
  final double marksObtained;
  final String? grade;
  final String? remarks;

  const ExamResult({
    required this.studentId,
    required this.marksObtained,
    this.grade,
    this.remarks,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      studentId: json['studentId'] as String? ?? '',
      marksObtained: (json['marksObtained'] as num?)?.toDouble() ?? 0.0,
      grade: json['grade'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'marksObtained': marksObtained,
      'grade': grade,
      'remarks': remarks,
    };
  }

  ExamResult copyWith({
    String? studentId,
    double? marksObtained,
    String? grade,
    String? remarks,
  }) {
    return ExamResult(
      studentId: studentId ?? this.studentId,
      marksObtained: marksObtained ?? this.marksObtained,
      grade: grade ?? this.grade,
      remarks: remarks ?? this.remarks,
    );
  }
}

class ExamModel {
  final String id;
  final String name;
  final String batchId;
  final String subjectId;
  final DateTime date;
  final int duration;
  final double totalMarks;
  final ExamStatus status;
  final DateTime createdAt;
  final List<ExamResult> results;

  const ExamModel({
    required this.id,
    required this.name,
    required this.batchId,
    required this.subjectId,
    required this.date,
    this.duration = 60,
    this.totalMarks = 100.0,
    this.status = ExamStatus.scheduled,
    required this.createdAt,
    this.results = const [],
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      date: _parseDateTime(json['date']),
      duration: json['duration'] as int? ?? 60,
      totalMarks: (json['totalMarks'] as num?)?.toDouble() ?? 100.0,
      status: ExamStatus.fromString(
          json['status'] as String? ?? 'scheduled'),
      createdAt: _parseDateTime(json['createdAt']),
      results: (json['results'] as List?)
              ?.map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'batchId': batchId,
      'subjectId': subjectId,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'totalMarks': totalMarks,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  ExamModel copyWith({
    String? id,
    String? name,
    String? batchId,
    String? subjectId,
    DateTime? date,
    int? duration,
    double? totalMarks,
    ExamStatus? status,
    DateTime? createdAt,
    List<ExamResult>? results,
  }) {
    return ExamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      batchId: batchId ?? this.batchId,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      totalMarks: totalMarks ?? this.totalMarks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      results: results ?? this.results,
    );
  }

  double get averageMarks {
    if (results.isEmpty) return 0.0;
    final total =
        results.fold(0.0, (s, result) => s + result.marksObtained);
    return total / results.length;
  }

  double get passPercentage {
    if (results.isEmpty) return 0.0;
    final passingMarks = totalMarks * 0.33;
    final passed =
        results.where((r) => r.marksObtained >= passingMarks).length;
    return (passed / results.length) * 100;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ExamModel(id: $id, name: $name, date: $date)';
}
