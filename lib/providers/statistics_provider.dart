import 'dart:developer';
import 'dart:io';

import 'package:app_tesis/services/statistics_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/error_handler.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statsService = StatisticsService();

  bool _isLoading = false;
  bool _isPollingActive = false;

  Map<String, dynamic>? _latestStats;

  bool get isLoading => _isLoading;
  bool get isPollingActive => _isPollingActive;

  Map<String, dynamic>? get latestStats => _latestStats;

  // Start processing
  Future<bool> startVideoProcessing({
    required File videoFile,
    required String fileName,
    required int assessmentId,
    required int sectionId,
    required int questionAmount,
  }) async {
    _isLoading = true;
    _latestStats = null;
    _isPollingActive = true;
    notifyListeners();

    try {
      await _statsService.uploadAndProcessVideo(
        videoFile: videoFile,
        fileName: fileName,
        assessmentId: assessmentId,
        sectionId: sectionId,
        questionAmount: questionAmount,
      );

      if (!_isPollingActive) {
        log('Video processing cancelled before polling started.');
        return false;
      }

      // If upload and processing initiation is successful, start polling
      final bool pollSuccess = await _pollForStatistics(assessmentId, sectionId);

      return pollSuccess;
    } on DioException catch (e) {
      log('DioException during video processing: ${e.message}');
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      log('Exception during video processing: ${e.toString()}');
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isPollingActive = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _pollForStatistics(int assessmentId, int sectionId) async {
    // 20 attempts, every 15 seconds = 5 minutes maximum wait time
    const int maxAttempts = 20; // Max polling attempts
    const Duration pollInterval = Duration(seconds: 15); // Interval between attempts

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(pollInterval);

      if (!_isPollingActive) {
        log('Polling cancelled for assessment $assessmentId, section $sectionId.');
        return false;
      }

      try {
        final statsData = await _statsService.getStatistics(assessmentId, sectionId);

        if (statsData['status'] == 'PROCESSED') {
          _latestStats = statsData['stats'] as Map<String, dynamic>?;
          log('Statistics available for assessment $assessmentId, section $sectionId.');
          return true;
        } else {
          log('Attempt ${i + 1}/$maxAttempts: Statistics not ready yet for assessment $assessmentId, section $sectionId. Current status: ${statsData['status']}');
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.badResponse && e.response?.statusCode == 404) {
          log('Attempt ${i + 1}/$maxAttempts: Statistics not ready yet for assessment $assessmentId, section $sectionId.');
        } else {
          log('Error while polling for statistics: ${e.message}');
          return false;
        }
      } catch (e) {
        log('Unexpected error while polling for statistics: $e');
        return false;
      }
    }

    log('Polling timed out: Statistics not available after $maxAttempts attempts for assessment $assessmentId, section $sectionId.');
    return false;
  }

  void cancelPolling() {
    log('Cancelling polling for statistics.');
    _isPollingActive = false;
  }

  // Fetch statistics
  Future<Map<String, dynamic>?> fetchStatistics(
      int assessmentId,
      int sectionId
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _statsService.getStatistics(assessmentId, sectionId);
      return stats;
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update statistics
  Future<void> updateStatistics(
      int assessmentId,
      int sectionId,
      List<Map<String, dynamic>>? newScores,
      String? status
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _statsService.updateStatistics(assessmentId, sectionId, newScores, status);
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete statistics
  Future<void> deleteStatistics(int assessmentId, int sectionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _statsService.deleteStatistics(assessmentId, sectionId);
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.getApiErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
