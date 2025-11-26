import 'package:app_tesis/models/section.dart';
import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/services/section_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/error_handler.dart';

class SectionProvider with ChangeNotifier {
  final ApiService _apiService;

  late final SectionService _sectionService;

  SectionProvider(this._apiService) {
    _sectionService = SectionService(_apiService);
  }

  List<Section> _sections = [];
  bool _isLoading = false;

  List<Section> get sections => _sections;
  bool get isLoading => _isLoading;

  void clearSectionsList() {
    _sections = [];
    _isLoading = true;
  }

  // Fetch all sections for a specific course in a specific semester
  Future<void> fetchSections(int idSemester, int idCourse) async {
    _isLoading = true;
    notifyListeners();

    try {
      _sections = await _sectionService.getSections(idSemester, idCourse);
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

  // Fetch all sections for a specific course in a specific semester returning the list
  Future<List<Section>> fetchSectionsList(int idSemester, int idCourse) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sections = await _sectionService.getSections(idSemester, idCourse);
      return sections;
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

  // Fetch section by ID
  Future<Section> fetchSectionById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final section = await _sectionService.getSectionById(id);
      return section;
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

  // Add a new section
  Future<void> addSection(
      String name,
      int idSemester,
      int idCourse,
      CourseInSemesterProvider courseInSemesterProvider
  ) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newSection = await _sectionService.createSection(
          name,
          idSemester,
          idCourse
      );
      _sections.add(newSection);
      courseInSemesterProvider.updateSectionCount(idSemester, idCourse, 1);
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

  // Update an existing section
  Future<void> updateSection(
      int id,
      String name
  ) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedSection = await _sectionService.updateSection(
          id,
          name
      );
      final index = _sections.indexWhere((section) => section.id == id);
      if (index != -1) {
        _sections[index] = updatedSection;
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

  // Soft delete an existing section
  Future<void> deleteSection(int id) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _sectionService.deleteSection(id);
      _sections.removeWhere((section) => section.id == id);
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
