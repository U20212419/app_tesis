import 'dart:developer';

import 'package:app_tesis/providers/assessment_provider.dart';
import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/providers/course_provider.dart';
import 'package:app_tesis/providers/section_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:app_tesis/providers/statistics_dashboard_provider.dart';
import 'package:app_tesis/providers/statistics_provider.dart';
import 'package:app_tesis/services/api_service.dart';
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

  log('Environment: $environment');

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
            create: (context) => CourseProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
            create: (context) => SemesterProvider(context.read<ApiService>())
        ),
        ChangeNotifierProvider(
            create: (context) => CourseInSemesterProvider(context.read<ApiService>())
        ),
        ChangeNotifierProvider(
            create: (context) => AssessmentProvider(context.read<ApiService>())
        ),
        ChangeNotifierProvider(
            create: (context) => SectionProvider(context.read<ApiService>())
        ),
        ChangeNotifierProvider(
            create: (context) => StatisticsProvider(context.read<ApiService>())
        ),
        ChangeNotifierProxyProvider5<
          StatisticsProvider,
          SemesterProvider,
          CourseProvider,
          AssessmentProvider,
          SectionProvider,
          StatisticsDashboardProvider>(
          create: (context) => StatisticsDashboardProvider.empty(),
          update: (context, statsProvider, semesterProvider, courseProvider,
              assessmentProvider, sectionProvider, previous) {
            if (previous == null) {
              return StatisticsDashboardProvider(
                statsProvider,
                semesterProvider,
                courseProvider,
                assessmentProvider,
                sectionProvider,
              );
            }

            previous.statisticsProvider = statsProvider;
            previous.semesterProvider = semesterProvider;
            previous.courseProvider = courseProvider;
            previous.assessmentProvider = assessmentProvider;
            previous.sectionProvider = sectionProvider;
            return previous;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}
