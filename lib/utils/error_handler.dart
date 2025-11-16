import 'dart:developer';

import 'package:app_tesis/services/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ErrorHandler {
  static String getApiErrorMessage(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.badResponse) {
        if (e.response?.data != null && e.response!.data is Map) {
          final data = e.response!.data;
          final errorCode = data['code'];
          final message = data['message'];

          String translatedMessage = _translateErrorCode(errorCode);

          // If the error code is not recognized, use the server message if available
          if (translatedMessage == 'Ha ocurrido un error inesperado.' &&
              message != null && message is String && message.isNotEmpty) {
            return message;
          }

          return translatedMessage;
        }
        return 'Error inesperado del servidor (código ${e.response?.statusCode}).';
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Tiempo de conexión agotado. Por favor, inténtelo de nuevo.';
      }

      if (e.type == DioExceptionType.connectionError) {
        return 'No se pudo conectar al servidor. Por favor, compruebe su conexión a Internet.';
      }

      return e.message ?? 'Error de red inesperado.';
    }

    log("Unknown API error: $e");
    return "Ocurrió un error inesperado.";
  }

  static String _translateErrorCode(String? code) {
    switch (code) {
      // Specific errors
      case 'ERR_INVALID_TOKEN':
        NavigationService.forceLogout();
        return 'El token de autenticación no es válido. Por favor, vuelva a ingresar.';
      case 'ERR_EXPIRED_TOKEN':
        NavigationService.forceLogout();
        return 'El token de autenticación ha expirado. Por favor, vuelva a ingresar.';
      case 'ERR_REVOKED_TOKEN':
        NavigationService.forceLogout();
        return 'El token de autenticación ha sido revocado. Por favor, vuelva a ingresar.';
      case 'ERR_COURSE_NOT_FOUND':
        return 'El curso solicitado no fue encontrado.';
      case 'ERR_SEMESTER_NOT_FOUND':
        return 'El semestre solicitado no fue encontrado.';
      case 'ERR_COURSE_IN_SEMESTER_NOT_FOUND':
        return 'El curso solicitado no fue encontrado en el semestre seleccionado.';
      case 'ERR_ASSESSMENT_NOT_FOUND':
        return 'La evaluación solicitada no fue encontrada.';
      case 'ERR_SECTION_NOT_FOUND':
        return 'El horario solicitado no fue encontrado.';
      case 'ERR_COURSE_CODE_DUPLICATE':
        return 'Ya existe un curso con el código ingresado.';
      case 'ERR_SEMESTER_KEY_DUPLICATE':
        return 'Ya existe un semestre con el año y número ingresados.';
      case 'ERR_COURSE_ALREADY_IN_SEMESTER':
        return 'El curso ya ha sido añadido al semestre seleccionado.';

      // Generic errors
      case 'ERR_AUTHENTICATION':
        NavigationService.forceLogout();
        return 'Ha ocurrido un error de autenticación. Por favor, vuelva a ingresar.';
      case 'ERR_RESOURCE_NOT_FOUND':
        return 'El recurso solicitado no fue encontrado.';
      case 'ERR_DUPLICATE_RESOURCE':
        return 'El recurso que se intenta crear ya existe.';

      // Fallback
      default:
        return 'Ha ocurrido un error inesperado.';
    }
  }

  // Handle login errors
 static String getLoginErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      log('FirebaseAuth error: ${e.code}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return 'Ya existe una cuenta con las mismas credenciales pero con otro método de inicio de sesión.';
        case 'invalid-credential':
          return 'Las credenciales proporcionadas no son válidas.';
        case 'operation-not-allowed':
          return 'El método de inicio de sesión no está habilitado.';
        case 'user-disabled':
          return 'La cuenta de usuario ha sido deshabilitada.';
        case 'user-not-found':
          return 'No se encontró ninguna cuenta con las credenciales proporcionadas.';
        case 'wrong-password':
          return 'La contraseña es incorrecta.';
        case 'invalid-verification-code':
          return 'El código de verificación proporcionado no es válido.';
        case 'invalid-verification-id':
          return 'El ID de verificación proporcionado no es válido.';
        case 'user-token-expired':
          NavigationService.forceLogout();
          return 'No se pudo obtener el token de acceso. Por favor, vuelva a ingresar.';
        default:
          return 'Ha ocurrido un error inesperado durante el inicio de sesión.';
      }
    }

    if (e is GoogleSignInException) {
      log('Google Sign-In error: ${e.code}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'El inicio de sesión fue cancelado por el usuario.';
      }
      return 'Ha ocurrido un error inesperado durante el inicio de sesión.';
    }

    if (e is Exception) {
      final message = e.toString();
      if (message.contains("No se pudo obtener el token de acceso.")) {
        return "No se pudo obtener el token de acceso.";
      }
    }

    // Generic fallback
    log('Unknown error: $e');
    return 'Ha ocurrido un error inesperado.';
  }
}
