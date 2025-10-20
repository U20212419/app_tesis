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

  // Fetch all courses from the service
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _courseService.getCourses();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCoursesDetailed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _courseService.getCoursesDetailed();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCourse(String courseName) async {
    try {
      // final newCourse = await _courseService.createCourse(courseName);
      // _courses.add(newCourse);

      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
