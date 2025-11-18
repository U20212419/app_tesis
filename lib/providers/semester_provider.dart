import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/semester.dart';
import '../services/api_service.dart';
import '../services/semester_service.dart';
import '../utils/error_handler.dart';

class SemesterProvider with ChangeNotifier {
  final ApiService _apiService;

  late final SemesterService _semesterService;

  SemesterProvider(this._apiService) {
    _semesterService = SemesterService(_apiService);
  }

  List<Semester> _semesters = [];
  bool _isLoading = false;

  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;

  // Update the course count when a course is added or removed from a semester
  void updateCourseCount(int semesterId, int newCount) {
    try {
      final semester = _semesters.firstWhere((sem) => sem.id == semesterId);
      semester.courseCount = newCount;
      notifyListeners();
    } catch (e) {
      log('Error updating course count: $e');
    }
  }

  // Fetch all semesters
  Future<void> fetchSemesters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _semesters = await _semesterService.getSemesters();
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

  // Fetch all semesters returning the list
  Future<List<Semester>> fetchSemestersList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final semesters = await _semesterService.getSemesters();
      return semesters;
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

  // Fetch all semesters with the amount of courses in each semester
  Future<void> fetchSemestersDetailed() async {
    _isLoading = true;
    notifyListeners();

    try {
      _semesters = await _semesterService.getSemestersDetailed();
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

  // Fetch semester by ID
  Future<Semester> fetchSemesterById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final semester = await _semesterService.getSemesterById(id);
      return semester;
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

  // Add a new semester
  Future<void> addSemester(String year, String number) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newSemester = await _semesterService.createSemester(year, number);
      _semesters.add(newSemester);
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

  // Update an existing semester
  Future<void> updateSemester(int id, String year, String number) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedSemester = await _semesterService.updateSemester(
          id, year, number);
      final index = _semesters.indexWhere((semester) => semester.id == id);
      if (index != -1) {
        _semesters[index] = updatedSemester;
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

  // Soft delete an existing semester
  Future<void> deleteSemester(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _semesterService.deleteSemester(id);
      _semesters.removeWhere((semester) => semester.id == id);
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
