class SubjectModel {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? gradeLevel;
  final String? category;

  const SubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.gradeLevel,
    this.category,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      description: json['description'] as String?,
      gradeLevel: json['gradeLevel'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'gradeLevel': gradeLevel,
      'category': category,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? gradeLevel,
    String? category,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SubjectModel(id: $id, name: $name, code: $code)';
}
