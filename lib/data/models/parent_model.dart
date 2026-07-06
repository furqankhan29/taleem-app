class ParentModel {
  final String id;
  final String name;
  final String? relation;
  final String? phone;
  final String? email;
  final String? whatsappNumber;
  final List<String> studentIds;
  final String? address;
  final String? occupation;
  final String? photoUrl;

  const ParentModel({
    required this.id,
    required this.name,
    this.relation,
    this.phone,
    this.email,
    this.whatsappNumber,
    this.studentIds = const [],
    this.address,
    this.occupation,
    this.photoUrl,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      studentIds: List<String>.from(json['studentIds'] as List? ?? []),
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'phone': phone,
      'email': email,
      'whatsappNumber': whatsappNumber,
      'studentIds': studentIds,
      'address': address,
      'occupation': occupation,
      'photoUrl': photoUrl,
    };
  }

  ParentModel copyWith({
    String? id,
    String? name,
    String? relation,
    String? phone,
    String? email,
    String? whatsappNumber,
    List<String>? studentIds,
    String? address,
    String? occupation,
    String? photoUrl,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      studentIds: studentIds ?? this.studentIds,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ParentModel(id: $id, name: $name, phone: $phone)';
}
