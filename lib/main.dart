import 'dart:developer';

import 'package:app_tesis/providers/assessment_provider.dart';
import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/providers/course_provider.dart';
import 'package:app_tesis/providers/section_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:app_tesis/providers/statistics_dashboard_provider.dart';
import 'package:app_tesis/providers/statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  try {
    await dotenv.load(
      fileName: environment == 'production'
          ? '.env.production'
          : '.env.development',
    );
  } catch (e) {
    log('Error loading .env file: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => SemesterProvider()),
        ChangeNotifierProvider(create: (_) => CourseInSemesterProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsDashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
