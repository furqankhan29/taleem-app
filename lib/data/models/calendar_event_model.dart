import 'package:cloud_firestore/cloud_firestore.dart';

enum CalendarEventType {
  holiday,
  exam,
  ptm,
  event,
  deadline;

  static CalendarEventType fromString(String value) {
    return CalendarEventType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CalendarEventType.event,
    );
  }
}

class CalendarEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? endDate;
  final CalendarEventType type;
  final List<String> participants;
  final String? createdBy;
  final String? color;

  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.endDate,
    this.type = CalendarEventType.event,
    this.participants = const [],
    this.createdBy,
    this.color,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      date: _parseDateTime(json['date']),
      endDate: _parseDateTimeNullable(json['endDate']),
      type: CalendarEventType.fromString(
          json['type'] as String? ?? 'event'),
      participants:
          List<String>.from(json['participants'] as List? ?? []),
      createdBy: json['createdBy'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'type': type.name,
      'participants': participants,
      'createdBy': createdBy,
      'color': color,
    };
  }

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDate,
    CalendarEventType? type,
    List<String>? participants,
    String? createdBy,
    String? color,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      createdBy: createdBy ?? this.createdBy,
      color: color ?? this.color,
    );
  }

  bool get isMultiDay => endDate != null && endDate != date;

  bool get isUpcoming => date.isAfter(DateTime.now());

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
      other is CalendarEventModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CalendarEventModel(id: $id, title: $title, type: ${type.name})';
}
