import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentStatus {
  active,
  inactive,
  graduated;

  static StudentStatus fromString(String value) {
    return StudentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StudentStatus.active,
    );
  }
}

enum FeeStatus {
  cleared,
  pending,
  overdue;

  static FeeStatus fromString(String value) {
    return FeeStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeeStatus.pending,
    );
  }
}

class StudentModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String studentId;
  final String? grade;
  final String? section;
  final String? stream;
  final String? bloodGroup;
  final String? parentId;
  final List<String> batchIds;
  final StudentStatus status;
  final FeeStatus feeStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? qrCodeData;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;

  const StudentModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    required this.studentId,
    this.grade,
    this.section,
    this.stream,
    this.bloodGroup,
    this.parentId,
    this.batchIds = const [],
    this.status = StudentStatus.active,
    this.feeStatus = FeeStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.qrCodeData,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      studentId: json['studentId'] as String? ?? '',
      grade: json['grade'] as String?,
      section: json['section'] as String?,
      stream: json['stream'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      parentId: json['parentId'] as String?,
      batchIds: List<String>.from(json['batchIds'] as List? ?? []),
      status: StudentStatus.fromString(json['status'] as String? ?? 'active'),
      feeStatus:
          FeeStatus.fromString(json['feeStatus'] as String? ?? 'pending'),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      qrCodeData: json['qrCodeData'] as String?,
      address: json['address'] as String?,
      dateOfBirth: _parseDateTimeNullable(json['dateOfBirth']),
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'studentId': studentId,
      'grade': grade,
      'section': section,
      'stream': stream,
      'bloodGroup': bloodGroup,
      'parentId': parentId,
      'batchIds': batchIds,
      'status': status.name,
      'feeStatus': feeStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'qrCodeData': qrCodeData,
      'address': address,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
    };
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? studentId,
    String? grade,
    String? section,
    String? stream,
    String? bloodGroup,
    String? parentId,
    List<String>? batchIds,
    StudentStatus? status,
    FeeStatus? feeStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? qrCodeData,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      studentId: studentId ?? this.studentId,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      stream: stream ?? this.stream,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      parentId: parentId ?? this.parentId,
      batchIds: batchIds ?? this.batchIds,
      status: status ?? this.status,
      feeStatus: feeStatus ?? this.feeStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

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
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'StudentModel(id: $id, name: $name, studentId: $studentId)';
}
