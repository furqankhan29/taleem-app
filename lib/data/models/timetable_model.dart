class TimetableSlot {
  final String startTime;
  final String endTime;
  final String subjectId;
  final String subjectName;
  final String? teacherId;
  final String? teacherName;
  final String? room;

  const TimetableSlot({
    required this.startTime,
    required this.endTime,
    required this.subjectId,
    required this.subjectName,
    this.teacherId,
    this.teacherName,
    this.room,
  });

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      teacherId: json['teacherId'] as String?,
      teacherName: json['teacherName'] as String?,
      room: json['room'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'room': room,
    };
  }

  TimetableSlot copyWith({
    String? startTime,
    String? endTime,
    String? subjectId,
    String? subjectName,
    String? teacherId,
    String? teacherName,
    String? room,
  }) {
    return TimetableSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      room: room ?? this.room,
    );
  }

  @override
  String toString() =>
      'TimetableSlot(startTime: $startTime, endTime: $endTime, subject: $subjectName)';
}

class TimetableModel {
  final String id;
  final String batchId;
  final int dayOfWeek;
  final List<TimetableSlot> slots;

  const TimetableModel({
    required this.id,
    required this.batchId,
    required this.dayOfWeek,
    this.slots = const [],
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      id: json['id'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      slots: (json['slots'] as List?)
              ?.map(
                  (e) => TimetableSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'dayOfWeek': dayOfWeek,
      'slots': slots.map((e) => e.toJson()).toList(),
    };
  }

  TimetableModel copyWith({
    String? id,
    String? batchId,
    int? dayOfWeek,
    List<TimetableSlot>? slots,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      slots: slots ?? this.slots,
    );
  }

  String get dayName {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) return days[dayOfWeek];
    return 'Unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TimetableModel(id: $id, batchId: $batchId, day: $dayName)';
}
