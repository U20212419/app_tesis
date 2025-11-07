import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';
import '../models/course_in_semester.dart';

class CourseInSemesterService {
  final ApiService _apiService = ApiService();

  // Get all courses in all semesters
  Future<List<CourseInSemester>> getCoursesInSemesters() async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.get(
        '/courses-in-semester/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((json) => CourseInSemester.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching courses in semesters: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Get all courses in a specific semester
  Future<List<CourseInSemester>> getCoursesInSemester(int idSemester) async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.get(
        '/courses-in-semester/$idSemester',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as List;
      return data.map((json) => CourseInSemester.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error fetching courses in the semester: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Add a course to a semester
  Future<CourseInSemester> addCourseToSemester(int idSemester, int idCourse) async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      final response = await _apiService.client.post(
        '/courses-in-semester/$idSemester/$idCourse',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return CourseInSemester.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error adding course to the semester: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Remove a course from a semester
  Future<void> removeCourseFromSemester(int idSemester, int idCourse) async {
    try {
      final String? token = await GoogleSignInService.getIdToken();

      if (token == null) {
        throw Exception(
            'Authentication token not found. User might be signed out.');
      }

      await _apiService.client.delete(
        '/courses-in-semester/$idSemester/$idCourse',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Error removing course from the semester: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
