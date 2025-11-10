import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/google_sign_in_service.dart';
import '../models/assessment.dart';
import 'api_service.dart';

class AssessmentService {
  final ApiService _apiService = ApiService();

  // Get all assessments for a specific course in a specific semester
  Future<List<Assessment>> getAssessments(int idSemester, int idCourse) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.get(
      '/assessments/$idSemester/$idCourse',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final data = response.data as List;
    return data.map((json) => Assessment.fromJson(json)).toList();
  }

  // Create a new assessment
  Future<Assessment> createAssessment(
      String type,
      String number,
      String? questionAmount,
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
      '/assessments/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'type': type,
        'number': number,
        'question_amount': questionAmount,
        'id_semester': idSemester,
        'id_course': idCourse,
      },
    );

    return Assessment.fromJson(response.data);
  }

  // Update an existing assessment
  Future<Assessment> updateAssessment(
      int id,
      String type,
      String number,
      String? questionAmount
  ) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    final response = await _apiService.client.put(
      '/assessments/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'type': type,
        'number': number,
        'question_amount': questionAmount,
      },
    );

    return Assessment.fromJson(response.data);
  }

  // Soft delete an assessment
  Future<void> deleteAssessment(int id) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    await _apiService.client.delete(
      '/assessments/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
