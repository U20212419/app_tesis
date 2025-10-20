import 'package:flutter/material.dart';

import '../models/semester.dart';
import '../services/semester_service.dart';

class SemesterProvider with ChangeNotifier {
  final SemesterService _semesterService = SemesterService();

  List<Semester> _semesters = [];
  bool _isLoading = false;
  String? _error;

  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all semesters from the service
  Future<void> fetchSemesters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _semesters = await _semesterService.getSemesters();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSemestersDetailed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _semesters = await _semesterService.getSemestersDetailed();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSemester(int year, int number) async {
    try {
      // final newSemester = await _semesterService.createSemester(year, number);
      // _semesters.add(newSemester);

      await fetchSemesters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
