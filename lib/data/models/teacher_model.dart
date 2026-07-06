import 'package:cloud_firestore/cloud_firestore.dart';

enum TeacherStatus {
  active,
  inactive,
  onLeave;

  static TeacherStatus fromString(String value) {
    return TeacherStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TeacherStatus.active,
    );
  }
}

class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? employeeId;
  final List<String> subjectIds;
  final List<String> batchIds;
  final String? qualification;
  final String? experience;
  final TeacherStatus status;
  final DateTime createdAt;
  final String? specialization;

  const TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.employeeId,
    this.subjectIds = const [],
    this.batchIds = const [],
    this.qualification,
    this.experience,
    this.status = TeacherStatus.active,
    required this.createdAt,
    this.specialization,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      employeeId: json['employeeId'] as String?,
      subjectIds: List<String>.from(json['subjectIds'] as List? ?? []),
      batchIds: List<String>.from(json['batchIds'] as List? ?? []),
      qualification: json['qualification'] as String?,
      experience: json['experience'] as String?,
      status:
          TeacherStatus.fromString(json['status'] as String? ?? 'active'),
      createdAt: _parseDateTime(json['createdAt']),
      specialization: json['specialization'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'employeeId': employeeId,
      'subjectIds': subjectIds,
      'batchIds': batchIds,
      'qualification': qualification,
      'experience': experience,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'specialization': specialization,
    };
  }

  TeacherModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? employeeId,
    List<String>? subjectIds,
    List<String>? batchIds,
    String? qualification,
    String? experience,
    TeacherStatus? status,
    DateTime? createdAt,
    String? specialization,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      employeeId: employeeId ?? this.employeeId,
      subjectIds: subjectIds ?? this.subjectIds,
      batchIds: batchIds ?? this.batchIds,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      specialization: specialization ?? this.specialization,
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
      other is TeacherModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TeacherModel(id: $id, name: $name, email: $email)';
}
