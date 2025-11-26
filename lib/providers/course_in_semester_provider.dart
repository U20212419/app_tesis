import 'dart:developer';

import 'package:app_tesis/providers/course_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/course_in_semester.dart';
import '../services/api_service.dart';
import '../services/course_in_semester_service.dart';
import '../utils/error_handler.dart';

class CourseInSemesterProvider with ChangeNotifier {
  final ApiService _apiService;

  late final CourseInSemesterService _courseInSemesterService;

  CourseInSemesterProvider(this._apiService) {
    _courseInSemesterService = CourseInSemesterService(_apiService);
  }

  List<CourseInSemester> _coursesInSemester = [];
  bool _isLoading = false;

  List<CourseInSemester> get courseInSemester => _coursesInSemester;
  bool get isLoading => _isLoading;

  void clearCoursesInSemesterList() {
    _coursesInSemester = [];
    _isLoading = true;
  }

  // Update the assessment count when an assessment is created or deleted
  void updateAssessmentCount(int idSemester, int idCourse, int counter) {
    try {
      final courseInSemester = _coursesInSemester.firstWhere(
          (cis) => cis.idSemester == idSemester && cis.course.id == idCourse);
      courseInSemester.assessmentCount =
          (courseInSemester.assessmentCount ?? 0) + counter;
      notifyListeners();
    } catch (e) {
      log('Error updating assessment count: $e');
    }
  }

  // Update the section count when a section is created or deleted
  void updateSectionCount(int idSemester, int idCourse, int counter) {
    try {
      final courseInSemester = _coursesInSemester.firstWhere(
          (cis) => cis.idSemester == idSemester && cis.course.id == idCourse);
      courseInSemester.sectionCount =
          (courseInSemester.sectionCount ?? 0) + counter;
      notifyListeners();
    } catch (e) {
      log('Error updating section count: $e');
    }
  }

  // Fetch all courses in all semesters
  Future<List<CourseInSemester>> fetchCoursesInSemesters() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _courseInSemesterService.getCoursesInSemesters();
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all courses in a specific semester
  Future<void> fetchCoursesInSemester(int idSemester) async {
    _isLoading = true;
    notifyListeners();

    try {
      _coursesInSemester = await _courseInSemesterService.getCoursesInSemester(idSemester);
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all courses in a specific semester returning the list
  Future<List<CourseInSemester>> fetchCoursesInSemesterList(int idSemester) async {
    _isLoading = true;
    notifyListeners();

    try {
      final coursesInSemester = await _courseInSemesterService.getCoursesInSemester(idSemester);
      return coursesInSemester;
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a course to a semester
  Future<void> addCourseToSemester(
      int idSemester,
      int idCourse,
      SemesterProvider semesterProvider,
      CourseProvider courseProvider
  ) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newCourseInSemester = await _courseInSemesterService.addCourseToSemester(idSemester, idCourse);
      _coursesInSemester.add(newCourseInSemester);
      semesterProvider.updateCourseCount(idSemester, _coursesInSemester.length);
      courseProvider.updateSemesterCount(idCourse, 1);
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove a course from a semester
  Future<void> removeCourseFromSemester(
      int idSemester,
      int idCourse,
      SemesterProvider semesterProvider,
      CourseProvider courseProvider
  ) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _courseInSemesterService.removeCourseFromSemester(idSemester, idCourse);
      _coursesInSemester.removeWhere((cis) => cis.idSemester == idSemester && cis.course.id == idCourse);
      semesterProvider.updateCourseCount(idSemester, _coursesInSemester.length);
      courseProvider.updateSemesterCount(idCourse, -1);
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
