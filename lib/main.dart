import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/providers/course_provider.dart';
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
      ],
      child: const MyApp(),
    ),
  );
}
