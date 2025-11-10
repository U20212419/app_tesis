import 'course.dart';

class CourseInSemester {
  final Course course;
  final int idSemester;
  int? assessmentCount;
  int? sectionCount;

  CourseInSemester({
    required this.course,
    required this.idSemester,
    this.assessmentCount = 0,
    this.sectionCount = 0,
  });

  factory CourseInSemester.fromJson(Map<String, dynamic> json) {
    return CourseInSemester(
      course: Course.fromJson(json['course']),
      idSemester: json['Semester_id_semester'],
      assessmentCount: json['assessment_count'],
      sectionCount: json['section_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'Semester_id_semester': idSemester,
      'assessment_count': assessmentCount,
      'section_count': sectionCount,
    };
  }
}
