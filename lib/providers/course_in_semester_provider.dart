import 'package:app_tesis/providers/course_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/course_in_semester.dart';
import '../services/course_in_semester_service.dart';
import '../utils/error_handler.dart';

class CourseInSemesterProvider with ChangeNotifier {
  final CourseInSemesterService _courseInSemesterService = CourseInSemesterService();

  List<CourseInSemester> _coursesInSemester = [];
  bool _isLoading = false;

  List<CourseInSemester> get courseInSemester => _coursesInSemester;
  bool get isLoading => _isLoading;

  void clearCoursesInSemesterList() {
    _coursesInSemester = [];
    _isLoading = true;
  }

  // Fetch all courses in all semesters
  Future<void> fetchCoursesInSemesters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _coursesInSemester = await _courseInSemesterService.getCoursesInSemesters();
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

  // Add a course to a semester
  Future<void> addCourseToSemester(
      int idSemester,
      int idCourse,
      SemesterProvider semesterProvider,
      CourseProvider courseProvider
  ) async {
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
