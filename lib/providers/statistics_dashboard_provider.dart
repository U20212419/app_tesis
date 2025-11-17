import 'package:app_tesis/models/assessment_section_id.dart';
import 'package:app_tesis/providers/section_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:app_tesis/providers/statistics_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/statistics_data.dart';
import '../utils/error_handler.dart';
import 'assessment_provider.dart';
import 'course_in_semester_provider.dart';

class StatisticsDashboardProvider with ChangeNotifier {
  List<StatisticsData> _statsList = [];
  List<StatisticsData> get statsList => _statsList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void addStats(StatisticsData data) {
    if (!statsList.any((s) => s.id == data.id)) {
      statsList.add(data);
      notifyListeners();
    }
  }

  void clearStats() {
    _statsList = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchAndAddStats({
    required BuildContext context,
    required int semesterId,
    required int courseId,
    required int assessmentId,
    required int sectionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
      final courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(context, listen: false);
      final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
      final sectionProvider = Provider.of<SectionProvider>(context, listen: false);

      final statsData = await statsProvider.fetchStatistics(
        assessmentId,
        sectionId,
      );

      await semesterProvider.fetchSemestersDetailed();
      final semester = semesterProvider.semesters.firstWhere((s) =>
      s.id == semesterId);
      await courseInSemesterProvider.fetchCoursesInSemester(semesterId);
      final course = courseInSemesterProvider.courseInSemester
          .firstWhere((cis) =>
      cis.idSemester == semesterId && cis.course.id == courseId)
          .course;
      await assessmentProvider.fetchAssessments(semesterId, courseId);
      final assessment = assessmentProvider.assessments
          .firstWhere((a) => a.id == assessmentId);
      await sectionProvider.fetchSections(semesterId, courseId);
      final section = sectionProvider.sections
          .firstWhere((s) => s.id == sectionId);

      final String semesterName = '${semester.year}-${semester.number}';
      final String courseName = '${course.code} - ${course.name}';
      final String assessmentName = '${assessment.type} ${assessment.number}';
      final String sectionName = section.name;

      final newData = StatisticsData(
        semesterName: semesterName,
        courseName: courseName,
        assessmentName: assessmentName,
        sectionName: sectionName,
        stats: statsData?['stats'] ?? {},
        id: AssessmentSectionId(
            assessmentId: assessmentId,
            sectionId: sectionId
        ),
      );

      addStats(newData);

      return statsData;
    } on DioException catch (e) {
      // If the error message is already formatted, use it directly
      if (e.message is String && e.message.toString().startsWith('Exception: ')) {
        rethrow;
      } else {
        final errorMessage = ErrorHandler.getApiErrorMessage(e);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      } else {
        final errorMessage = ErrorHandler.getLoginErrorMessage(e);
        throw Exception(errorMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
