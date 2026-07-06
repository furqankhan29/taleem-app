import 'package:cloud_firestore/cloud_firestore.dart';

enum ExportFormat {
  pdf,
  excel,
  csv;

  static ExportFormat fromString(String value) {
    return ExportFormat.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExportFormat.pdf,
    );
  }
}

enum ExportStatus {
  processing,
  completed,
  failed;

  static ExportStatus fromString(String value) {
    return ExportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExportStatus.processing,
    );
  }
}

class ExportLogModel {
  final String id;
  final String reportTitle;
  final ExportFormat format;
  final ExportStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? fileUrl;
  final String? filePath;
  final int? fileSize;
  final Map<String, dynamic> filters;
  final String? errorMessage;

  const ExportLogModel({
    required this.id,
    required this.reportTitle,
    required this.format,
    this.status = ExportStatus.processing,
    required this.createdAt,
    this.completedAt,
    this.fileUrl,
    this.filePath,
    this.fileSize,
    this.filters = const {},
    this.errorMessage,
  });

  factory ExportLogModel.fromJson(Map<String, dynamic> json) {
    return ExportLogModel(
      id: json['id'] as String? ?? '',
      reportTitle: json['reportTitle'] as String? ?? '',
      format: ExportFormat.fromString(json['format'] as String? ?? 'pdf'),
      status: ExportStatus.fromString(json['status'] as String? ?? 'processing'),
      createdAt: _parseDateTime(json['createdAt']),
      completedAt: _parseDateTimeNullable(json['completedAt']),
      fileUrl: json['fileUrl'] as String?,
      filePath: json['filePath'] as String?,
      fileSize: json['fileSize'] as int?,
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportTitle': reportTitle,
      'format': format.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'fileUrl': fileUrl,
      'filePath': filePath,
      'fileSize': fileSize,
      'filters': filters,
      'errorMessage': errorMessage,
    };
  }

  ExportLogModel copyWith({
    String? id,
    String? reportTitle,
    ExportFormat? format,
    ExportStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? fileUrl,
    String? filePath,
    int? fileSize,
    Map<String, dynamic>? filters,
    String? errorMessage,
  }) {
    return ExportLogModel(
      id: id ?? this.id,
      reportTitle: reportTitle ?? this.reportTitle,
      format: format ?? this.format,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      fileUrl: fileUrl ?? this.fileUrl,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get statusLabel {
    switch (status) {
      case ExportStatus.processing:
        return 'Processing';
      case ExportStatus.completed:
        return 'Completed';
      case ExportStatus.failed:
        return 'Failed';
    }
  }

  bool get isCompleted => status == ExportStatus.completed;

  bool get isFailed => status == ExportStatus.failed;

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
}
