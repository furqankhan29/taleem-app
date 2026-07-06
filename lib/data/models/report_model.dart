import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  attendance,
  fee,
  performance,
  income;

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportType.attendance,
    );
  }
}

enum ReportFormat {
  pdf,
  excel,
  csv;

  static ReportFormat fromString(String value) {
    return ReportFormat.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportFormat.pdf,
    );
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: _parseDateTime(json['start']),
      end: _parseDateTime(json['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
    };
  }

  DateRange copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return DateRange(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  int get durationInDays => end.difference(start).inDays;

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

class ReportModel {
  final String id;
  final String title;
  final ReportType type;
  final DateRange dateRange;
  final String? generatedBy;
  final DateTime generatedAt;
  final String? fileUrl;
  final ReportFormat format;
  final Map<String, dynamic> data;

  const ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dateRange,
    this.generatedBy,
    required this.generatedAt,
    this.fileUrl,
    this.format = ReportFormat.pdf,
    this.data = const {},
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: ReportType.fromString(json['type'] as String? ?? 'attendance'),
      dateRange: json['dateRange'] != null
          ? DateRange.fromJson(json['dateRange'] as Map<String, dynamic>)
          : DateRange(start: DateTime.now(), end: DateTime.now()),
      generatedBy: json['generatedBy'] as String?,
      generatedAt: _parseDateTime(json['generatedAt']),
      fileUrl: json['fileUrl'] as String?,
      format:
          ReportFormat.fromString(json['format'] as String? ?? 'pdf'),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'dateRange': dateRange.toJson(),
      'generatedBy': generatedBy,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'fileUrl': fileUrl,
      'format': format.name,
      'data': data,
    };
  }

  ReportModel copyWith({
    String? id,
    String? title,
    ReportType? type,
    DateRange? dateRange,
    String? generatedBy,
    DateTime? generatedAt,
    String? fileUrl,
    ReportFormat? format,
    Map<String, dynamic>? data,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateRange: dateRange ?? this.dateRange,
      generatedBy: generatedBy ?? this.generatedBy,
      generatedAt: generatedAt ?? this.generatedAt,
      fileUrl: fileUrl ?? this.fileUrl,
      format: format ?? this.format,
      data: data ?? this.data,
    );
  }

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ReportModel(id: $id, title: $title, type: ${type.name})';
}
