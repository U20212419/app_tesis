class Section {
  final int id;
  final String name;
  final int idSemester;
  final int idCourse;

  Section({
    required this.id,
    required this.name,
    required this.idSemester,
    required this.idCourse,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id_section'],
      name: json['name'],
      idSemester: json['id_semester'],
      idCourse: json['id_course'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_section': id,
      'name': name,
      'id_semester': idSemester,
      'id_course': idCourse,
    };
  }
}
