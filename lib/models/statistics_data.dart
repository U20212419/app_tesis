import 'package:app_tesis/models/assessment_section_id.dart';

class StatisticsData {
  final String semesterName;
  final String courseName;
  final String assessmentName;
  final String sectionName;
  final Map<String, dynamic> stats;
  final AssessmentSectionId id;

  StatisticsData({
    required this.semesterName,
    required this.courseName,
    required this.assessmentName,
    required this.sectionName,
    required this.stats,
    required this.id,
  });
}
