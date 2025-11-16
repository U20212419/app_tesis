import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/google_sign_in_service.dart';
import 'api_service.dart';

class StatisticsService {
  final ApiService _apiService = ApiService();

  Future<Map<String, String>> _getUploadUrl(String fileName) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    log('Requesting upload URL for file: $fileName');
    final response = await _apiService.client.post(
      '/video-processing/generate-upload-url',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'file_name': fileName,
      },
    );
    log('Received upload URL response: ${response.data}');

    final data = {
      'upload_url': response.data['upload_url'] as String,
      'download_url': response.data['download_url'] as String,
    };
    return data;
  }

  Future<void> _uploadVideoToS3(String uploadUrl, File videoFile) async {
    final dio = Dio();

    log('Uploading video to S3 at URL: $uploadUrl');
    await dio.put(
      uploadUrl,
      data: videoFile.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: await videoFile.length(),
          Headers.contentTypeHeader: 'video/mp4',
        }
      )
    );
    log('Video uploaded to S3 successfully.');
  }

  Future<void> _triggerProcessing(
      String downloadUrl,
      int assessmentId,
      int sectionId,
      int questionAmount
  ) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    log('Triggering video processing for URL: $downloadUrl');
    await _apiService.client.post(
      '/video-processing/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        's3_url': downloadUrl,
        'id_assessment': assessmentId,
        'id_section': sectionId,
        'question_amount': questionAmount,
      }
    );
    log('Video processing triggered successfully.');
  }

  Future<void> uploadAndProcessVideo({
    required File videoFile,
    required String fileName,
    required int assessmentId,
    required int sectionId,
    required int questionAmount
  }) async {
    // Get pre-signed upload and download URLs
    final urls = await _getUploadUrl(fileName);
    final uploadUrl = urls['upload_url']!;
    final downloadUrl = urls['download_url']!;

    // Upload video to S3
    await _uploadVideoToS3(uploadUrl, videoFile);

    // Notify backend to start processing
    await _triggerProcessing(downloadUrl, assessmentId, sectionId, questionAmount);
  }

  // Fetch statistics for a given assessment and section
  Future<Map<String, dynamic>> getStatistics(int assessmentId, int sectionId) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    log('Fetching statistics for assessment $assessmentId, section $sectionId.');
    final response = await _apiService.client.get(
      '/statistics/$assessmentId/$sectionId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    log('Received statistics response: ${response.data}');

    return response.data as Map<String, dynamic>;
  }

  // Update statistics for a given assessment and section
  Future<void> updateStatistics(
      int assessmentId,
      int sectionId,
      List<Map<String, dynamic>>? scores,
      String? status
  ) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    log('Updating statistics for assessment $assessmentId, section $sectionId with data: $scores and status: $status.');
    await _apiService.client.put(
      '/statistics/$assessmentId/$sectionId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      data: {
        'scores': scores,
        'status': status,
      }
    );
    log('Statistics updated successfully.');
  }

  // Delete statistics for a given assessment and section
  Future<void> deleteStatistics(int assessmentId, int sectionId) async {
    final String? token = await GoogleSignInService.getIdToken();

    if (token == null) {
      throw FirebaseAuthException(
          code: 'user-token-expired',
          message: 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.'
      );
    }

    log('Deleting statistics for assessment $assessmentId, section $sectionId.');
    await _apiService.client.delete(
      '/statistics/$assessmentId/$sectionId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    log('Statistics deleted successfully.');
  }
}
