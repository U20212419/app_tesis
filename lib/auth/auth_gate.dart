import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../screens/main_screen.dart';
import '../theme/app_colors.dart';
import '../utils/error_handler.dart';
import '../utils/size_config.dart';
import '../widgets/action_button.dart';
import '../widgets/custom_toast.dart';
import 'google_sign_in_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.highlightDarkest,
                ),
              ),
            );
          }

          // User logged in
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // User not logged in
          return Scaffold(
            body: Center(
              child: _isLoggingIn
                  ? const CircularProgressIndicator(
                color: AppColors.highlightDarkest,
              )
                  : ActionButton(
                icon: Symbols.login_rounded,
                label: 'Iniciar sesión con Google',
                accentColor: AppColors.highlightDarkest,
                onTap: () async {
                  setState(() {
                    _isLoggingIn = true;
                  });
                  try {
                    await GoogleSignInService.signInWithGoogle();
                  } catch (e) {
                    if (context.mounted) {
                      final errorMessage = ErrorHandler.getLoginErrorMessage(e);
                      CustomToast.show(
                        context: context,
                        title: 'Error al iniciar sesión',
                        detail: errorMessage,
                        type: CustomToastType.error,
                        position: ToastPosition.bottom,
                      );
                      setState(() {
                        _isLoggingIn = false;
                      });
                    }
                  }
                },
                width: SizeConfig.scaleWidth(50),
                height: SizeConfig.scaleHeight(10),
              ),
            ),
          );
        }
    );
  }
}
