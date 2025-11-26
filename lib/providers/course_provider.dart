import 'dart:developer';

import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/api_service.dart';
import '../services/course_service.dart';
import '../utils/error_handler.dart';

class CourseProvider with ChangeNotifier {
  final ApiService _apiService;

  late final CourseService _courseService;

  CourseProvider(this._apiService) {
    _courseService = CourseService(_apiService);
  }

  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  // Update the semester count when a course is added or removed from a semester
  void updateSemesterCount(int courseId, int counter) {
    try {
      final course = _courses.firstWhere((c) => c.id == courseId);
      course.semesterCount = (course.semesterCount ?? 0) + counter;
      notifyListeners();
    } catch (e) {
      log('Error updating semester count: $e');
    }
  }

  // Decrement the semester count by 1
  void decrementSemesterCount(int courseId) {
    try {
      final index = _courses.indexWhere((c) => c.id == courseId);

      if (index != -1 && _courses[index].semesterCount != null) {
        _courses[index].semesterCount = _courses[index].semesterCount! - 1;
        notifyListeners();
      }
    } catch (e) {
      log('Error decrementing semester count: $e');
    }
  }

  // Fetch all courses
  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _courseService.getCourses();
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

  // Fetch all courses with the amount of semesters in which each course is present
  Future<void> fetchCoursesDetailed() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _courseService.getCoursesDetailed();
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

  // Fetch course by ID
  Future<Course> fetchCourseById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final course = await _courseService.getCourseById(id);
      return course;
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

  // Add a new course
  Future<void> addCourse(String code, String name) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newCourse = await _courseService.createCourse(code, name);
      _courses.add(newCourse);
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

  // Update an existing course
  Future<void> updateCourse(int id, String code, String name) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedCourse = await _courseService.updateCourse(id, code, name);
      final index = _courses.indexWhere((course) => course.id == id);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }
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

  // Soft delete an existing course
  Future<void> deleteCourse(
      int id,
      SemesterProvider semesterProvider,
      CourseInSemesterProvider courseInSemesterProvider
  ) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final coursesInSemesters = await courseInSemesterProvider.fetchCoursesInSemesters();
      final affectedSemesterIds = coursesInSemesters
          .where((cis) => cis.course.id == id)
          .map((cis) => cis.idSemester)
          .toSet();
      await _courseService.deleteCourse(id);
      _courses.removeWhere((course) => course.id == id);
      for (final semesterId in affectedSemesterIds) {
        semesterProvider.decrementCourseCount(semesterId);
      }
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
