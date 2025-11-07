import 'package:flutter/material.dart';

import '../models/course_in_semester.dart';
import '../services/course_in_semester_service.dart';

class CourseInSemesterProvider with ChangeNotifier {
  final CourseInSemesterService _courseInSemesterService = CourseInSemesterService();

  List<CourseInSemester> _coursesInSemester = [];
  bool _isLoading = false;
  String? _error;

  List<CourseInSemester> get courseInSemester => _coursesInSemester;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all courses in all semesters
  Future<void> fetchCoursesInSemesters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coursesInSemester = await _courseInSemesterService.getCoursesInSemesters();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all courses in a specific semester
  Future<void> fetchCoursesInSemester(int idSemester) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _coursesInSemester = await _courseInSemesterService.getCoursesInSemester(idSemester);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a course to a semester
  Future<void> addCourseToSemester(int idSemester, int idCourse) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCourseInSemester = await _courseInSemesterService.addCourseToSemester(idSemester, idCourse);
      _coursesInSemester.add(newCourseInSemester);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove a course from a semester
  Future<void> removeCourseFromSemester(int idSemester, int idCourse) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _courseInSemesterService.removeCourseFromSemester(idSemester, idCourse);
      _coursesInSemester.removeWhere((cis) => cis.idSemester == idSemester && cis.course.id == idCourse);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
