import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';
import '../models/semester.dart';

class SemesterService {
  final ApiService _apiService = ApiService();

  // Get all semesters
  Future<List<Semester>> getSemesters() async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.get(
        '/semesters/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((json) => Semester.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching semesters: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Get a specific semester by ID
  Future<Semester> getSemester(int id) async {
    try {
      final response = await _apiService.client.get('/semesters/$id');
      return Semester.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching semester $id: $e');
    }
  }

  // Get all semesters including the amount of courses that are present in each semester
  Future<List<Semester>> getSemestersDetailed() async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.get(
        '/semesters/detailed',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((json) => Semester.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching semesters: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Create a new semester
  Future<Semester> createSemester(int year, int number) async {
    try {
      final response = await _apiService.client.post(
        '/semesters/',
        data: {
          'year': year,
          'number': number,
        },
      );
      return Semester.fromJson(response.data);
    } catch (e) {
      throw Exception('Error creating semester: $e');
    }
  }

  // Update an existing semester
  Future<Semester> updateSemester(int id, int year, int number) async {
    try {
      final response = await _apiService.client.put(
        '/semesters/$id',
        data: {
          'year': year,
          'number': number,
        },
      );
      return Semester.fromJson(response.data);
    } catch (e) {
      throw Exception('Error updating semester $id: $e');
    }
  }

  // Delete a semester
  Future<void> deleteSemester(int id) async {
    try {
      await _apiService.client.delete('/semesters/$id');
    } catch (e) {
      throw Exception('Error deleting semester $id: $e');
    }
  }
}
