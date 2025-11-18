import 'package:app_tesis/models/assessment.dart';
import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/assessment_service.dart';
import '../utils/error_handler.dart';

class AssessmentProvider with ChangeNotifier {
  final ApiService _apiService;

  late final AssessmentService _assessmentService;

  AssessmentProvider(this._apiService) {
    _assessmentService = AssessmentService(_apiService);
  }

  List<Assessment> _assessments = [];
  bool _isLoading = false;

  List<Assessment> get assessments => _assessments;
  bool get isLoading => _isLoading;

  void clearAssessmentsList() {
    _assessments = [];
    _isLoading = true;
  }

  // Fetch all assessments for a specific course in a specific semester
  Future<void> fetchAssessments(int idSemester, int idCourse) async {
    _isLoading = true;
    notifyListeners();

    try {
      _assessments = await _assessmentService.getAssessments(idSemester, idCourse);
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

  // Fetch all assessments for a specific course in a specific semester returning the list
  Future<List<Assessment>> fetchAssessmentsList(int idSemester, int idCourse) async {
    _isLoading = true;
    notifyListeners();

    try {
      final assessments = await _assessmentService.getAssessments(idSemester, idCourse);
      return assessments;
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

  // Fetch assessment by ID
  Future<Assessment> fetchAssessmentById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final assessment = await _assessmentService.getAssessmentById(id);
      return assessment;
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

  // Add a new assessment
  Future<void> addAssessment(
      String type,
      String number,
      String? questionAmount,
      int idSemester,
      int idCourse,
      CourseInSemesterProvider courseInSemesterProvider
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAssessment = await _assessmentService.createAssessment(
        type,
        number,
        questionAmount,
        idSemester,
        idCourse
      );
      _assessments.add(newAssessment);
      courseInSemesterProvider.updateAssessmentCount(idSemester, idCourse, 1);
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

  // Update an existing assessment
  Future<void> updateAssessment(
      int id,
      String type,
      String number,
      String? questionAmount
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedAssessment = await _assessmentService.updateAssessment(
        id,
        type,
        number,
        questionAmount
      );
      final index = _assessments.indexWhere((assessment) => assessment.id == id);
      if (index != -1) {
        _assessments[index] = updatedAssessment;
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

  // Soft delete an existing assessment
  Future<void> deleteAssessment(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _assessmentService.deleteAssessment(id);
      _assessments.removeWhere((assessment) => assessment.id == id);
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
