class Course {
  final int id;
  final String name;
  final String code;
  final int semesterCount;

  Course({
    required this.id,
    required this.name,
    required this.code,
    this.semesterCount = 0,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id_course'],
      name: json['name'],
      code: json['code'],
      semesterCount: json['semester_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_course': id,
      'name': name,
      'code': code,
      'semester_count': semesterCount,
    };
  }
}
