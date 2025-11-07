import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';
import '../models/course.dart';

class CourseService {
  final ApiService _apiService = ApiService();

  // Get all courses
  Future<List<Course>> getCourses() async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.get(
        '/courses/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((json) => Course.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching courses: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Get all courses including the amount of semesters in which each course is present
  Future<List<Course>> getCoursesDetailed() async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.get(
        '/courses/detailed',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((json) => Course.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching courses: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Create a new course
  Future<Course> createCourse(String code, String name) async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.post(
        '/courses/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'code': code,
          'name': name,
        },
      );

      return Course.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error creating course: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Update an existing course
  Future<Course> updateCourse(int id, String code, String name) async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.put(
        '/courses/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'code': code,
          'name': name,
        },
      );

      return Course.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error editing course: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Soft delete a course
  Future<void> deleteCourse(int id) async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      await _apiService.client.delete(
        '/courses/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Error deleting course: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
