import 'package:app_tesis/models/section.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/google_sign_in_service.dart';
import 'api_service.dart';

class SectionService {
  final ApiService _apiService = ApiService();

  // Get all sections for a specific course in a specific semester
  Future<List<Section>> getSections(int idSemester, int idCourse) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.get(
      '/sections/$idSemester/$idCourse',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data as List;
    return data.map((json) => Section.fromJson(json)).toList();
  }

  // Create a new section
  Future<Section> createSection(
      String name,
      int idSemester,
      int idCourse
  ) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.post(
      '/sections/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'name': name,
        'id_semester': idSemester,
        'id_course': idCourse,
      },
    );

    return Section.fromJson(response.data);
  }

  // Update an existing section
  Future<Section> updateSection(
      int id,
      String name
  ) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.put(
      '/sections/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'name': name,
      },
    );

    return Section.fromJson(response.data);
  }

  // Soft delete a section
  Future<void> deleteSection(int id) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    await _apiService.client.delete(
      '/sections/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
