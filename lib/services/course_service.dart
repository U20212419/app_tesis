import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'api_service.dart';
import '../models/course.dart';

class CourseService {
  final ApiService _apiService = ApiService();

  // Get all courses
  Future<List<Course>> getCourses() async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Get all courses including the amount of semesters in which each course is present
  Future<List<Course>> getCoursesDetailed() async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Create a new course
  Future<Course> createCourse(String code, String name) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Update an existing course
  Future<Course> updateCourse(int id, String code, String name) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Soft delete a course
  Future<void> deleteCourse(int id) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    await _apiService.client.delete(
      '/courses/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
