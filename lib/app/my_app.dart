import 'package:app_tesis/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../utils/size_config.dart';
import '../widgets/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        SizeConfig.init(context);

        return MaterialApp(
          title: 'App Tesis',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        );
      },
    );
  }
}
