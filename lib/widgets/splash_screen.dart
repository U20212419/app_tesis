import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../auth/auth_gate.dart';
import '../auth/google_sign_in_service.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    try {
      final isRelease = kReleaseMode; // True when flutter build, false when run
      final fileName = isRelease ? '.env.production' : '.env.development';
      await dotenv.load(fileName: fileName);

      await Firebase.initializeApp();

      if (kDebugMode) {
        await GoogleSignInService.signOut();
        log("User signed out for debug purposes.");
      }

      await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    log('Error during initialization: $e');
  }

  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.highlightDarkest,
        ),
      ),
    );
  }
}
