import 'dart:developer';

import 'package:app_tesis/auth/google_sign_in_service.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> forceLogout() async {
    log("Forcing user logout...");
    await GoogleSignInService.signOut();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/', (Route<dynamic> route) => false
    );
  }
}
