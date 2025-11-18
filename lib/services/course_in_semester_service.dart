import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'api_service.dart';
import '../models/course_in_semester.dart';

class CourseInSemesterService {
  final ApiService _apiService;

  CourseInSemesterService(this._apiService);

  // Get all courses in all semesters
  Future<List<CourseInSemester>> getCoursesInSemesters() async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Get all courses in a specific semester
  Future<List<CourseInSemester>> getCoursesInSemester(int idSemester) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Add a course to a semester
  Future<CourseInSemester> addCourseToSemester(int idSemester, int idCourse) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Remove a course from a semester
  Future<void> removeCourseFromSemester(int idSemester, int idCourse) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    await _apiService.client.delete(
      '/courses-in-semester/$idSemester/$idCourse',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
