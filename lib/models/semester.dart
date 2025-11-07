class Semester {
  final int id;
  final int year;
  final int number;
  final int? courseCount;

  Semester({
    required this.id,
    required this.year,
    required this.number,
    this.courseCount = 0,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id_semester'],
      year: json['year'],
      number: json['number'],
      courseCount: json['course_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_semester': id,
      'year': year,
      'number': number,
      'course_count': courseCount,
    };
  }
}
