import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'api_service.dart';
import '../models/semester.dart';

class SemesterService {
  final ApiService _apiService;

  SemesterService(this._apiService);

  // Get all semesters
  Future<List<Semester>> getSemesters() async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Get all semesters including the amount of courses that are present in each semester
  Future<List<Semester>> getSemestersDetailed() async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
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
  }

  // Get a semester by ID
  Future<Semester> getSemesterById(int id) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.get(
      '/semesters/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return Semester.fromJson(response.data);
  }

  // Create a new semester
  Future<Semester> createSemester(String year, String number) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.post(
      '/semesters/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'year': year,
        'number': number,
      },
    );

    return Semester.fromJson(response.data);
  }

  // Update an existing semester
  Future<Semester> updateSemester(int id, String year, String number) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.put(
      '/semesters/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'year': year,
        'number': number,
      },
    );

    return Semester.fromJson(response.data);
  }

  // Soft delete a semester
  Future<void> deleteSemester(int id) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    await _apiService.client.delete(
      '/semesters/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
