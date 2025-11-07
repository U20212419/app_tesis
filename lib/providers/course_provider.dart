import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/course_service.dart';

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all courses
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _courseService.getCourses();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all courses with the amount of semesters in which each course is present
  Future<void> fetchCoursesDetailed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _courseService.getCoursesDetailed();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new course
  Future<void> addCourse(String code, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCourse = await _courseService.createCourse(code, name);
      _courses.add(newCourse);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing course
  Future<void> updateCourse(int id, String code, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCourse = await _courseService.updateCourse(id, code, name);
      final index = _courses.indexWhere((course) => course.id == id);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Soft delete an existing course
  Future<void> deleteCourse(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _courseService.deleteCourse(id);
      _courses.removeWhere((course) => course.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
