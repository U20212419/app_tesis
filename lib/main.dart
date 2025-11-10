import 'package:app_tesis/providers/assessment_provider.dart';
import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/providers/course_provider.dart';
import 'package:app_tesis/providers/section_provider.dart';
import 'package:app_tesis/providers/semester_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => SemesterProvider()),
        ChangeNotifierProvider(create: (_) => CourseInSemesterProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
