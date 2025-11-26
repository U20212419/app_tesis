import 'package:app_tesis/models/assessment_section_id.dart';
import 'package:app_tesis/providers/section_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:app_tesis/providers/statistics_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/statistics_data.dart';
import '../utils/error_handler.dart';
import 'assessment_provider.dart';
import 'course_provider.dart';

class StatisticsDashboardProvider with ChangeNotifier {
  late StatisticsProvider statisticsProvider;
  late SemesterProvider semesterProvider;
  late CourseProvider courseProvider;
  late AssessmentProvider assessmentProvider;
  late SectionProvider sectionProvider;

  StatisticsDashboardProvider(
    this.statisticsProvider,
    this.semesterProvider,
    this.courseProvider,
    this.assessmentProvider,
    this.sectionProvider,
  );

  StatisticsDashboardProvider.empty();

  Set<StatisticsData> _statsList = {};
  Set<StatisticsData> get statsList => _statsList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void addStats(StatisticsData data) {
    if (!statsList.any((s) => s.id == data.id)) {
      statsList.add(data);
      notifyListeners();
    }
  }

  void clearStats() {
    _statsList = {};
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
      final statsData = await statisticsProvider.fetchStatistics(
        assessmentId,
        sectionId,
      );

      final semester = await semesterProvider.fetchSemesterById(semesterId);
      final course = await courseProvider.fetchCourseById(courseId);
      final assessment = await assessmentProvider.fetchAssessmentById(assessmentId);
      final section = await sectionProvider.fetchSectionById(sectionId);

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
