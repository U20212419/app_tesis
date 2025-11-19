import 'dart:async';

import 'package:app_tesis/models/assessment_section_id.dart';
import 'package:app_tesis/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assessment.dart';
import '../models/course.dart';
import '../models/section.dart';
import '../models/semester.dart';
import '../providers/assessment_provider.dart';
import '../providers/course_in_semester_provider.dart';
import '../providers/section_provider.dart';
import '../providers/semester_provider.dart';
import '../screens/main_screen.dart';
import '../screens/statistics/statistics_dashboard_screen.dart';
import '../utils/size_config.dart';
import 'custom_dialog.dart';
import 'custom_dropdown_field.dart';

typedef OnSelectionComplete = FutureOr<Map<String, dynamic>?> Function(Map<String, int> selectedIds);

Future<void> showDashboardAddAssessmentDialog({
  required BuildContext context,
  required OnSelectionComplete onSelectionComplete,
  Set<AssessmentSectionId> usedIds = const {},
}) async {
  final dialogContext = context;

  final formKey = GlobalKey<FormState>();

  Semester? selectedSemester;
  Course? selectedCourse;
  Assessment? selectedAssessment;
  Section? selectedSection;

  List<Semester> semesters = [];
  List<Course> courses = [];
  List<Assessment> assessments = [];
  List<Section> sections = [];

  final semesterProvider = Provider.of<SemesterProvider>(dialogContext, listen: false);
  final courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(dialogContext, listen: false);
  final assessmentProvider = Provider.of<AssessmentProvider>(dialogContext, listen: false);
  final sectionProvider = Provider.of<SectionProvider>(dialogContext, listen: false);

  final semestersList = await semesterProvider.fetchSemestersList();
  semesters = semestersList;

  if (!dialogContext.mounted) return;

  return showCustomDialog(
    context: dialogContext,
    title: 'Añadir Evaluación',
    color: AppColors.highlightDarkest,
    actionButtonText: 'Añadir',
    body: StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Semester dropdown
              CustomDropdownField<Semester>(
                label: 'Semestre',
                hintText: 'Seleccione un semestre',
                value: selectedSemester,
                items: semesters,
                itemLabel: (semester) => '${semester.year}-${semester.number}',
                onChanged: (semester) async {
                  setState(() {
                    selectedSemester = semester;

                    // Reset dependent selections
                    selectedCourse = null;
                    selectedAssessment = null;
                    selectedSection = null;

                    courses = [];
                    assessments = [];
                    sections = [];
                  });

                  if (semester == null) return;

                  // Load courses for the selected semester
                  final coursesList = await courseInSemesterProvider.fetchCoursesInSemesterList(semester.id);

                  if (!dialogContext.mounted) return;

                  setState(() {
                    courses = coursesList.map((e) => e.course).toList();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione un semestre.';
                  }
                  return null;
                },
              ),
              SizedBox(height: SizeConfig.scaleHeight(2.3)),
              // Course dropdown
              CustomDropdownField<Course>(
                label: 'Curso',
                hintText: 'Seleccione un curso',
                value: selectedCourse,
                items: courses,
                itemLabel: (course) => '${course.code} - ${course.name}',
                onChanged: (course) async {
                  setState(() {
                    selectedCourse = course;

                    // Reset dependent selections
                    selectedAssessment = null;
                    selectedSection = null;

                    assessments = [];
                    sections = [];
                  });

                  if (course == null || selectedSemester == null) return;

                  final semesterId = selectedSemester!.id;
                  final courseId = course.id;

                  // Load assessments and sections for the selected course and semester
                  final assessmentsList = await assessmentProvider.fetchAssessmentsList(
                      semesterId,
                      courseId
                  );
                  final sectionsList = await sectionProvider.fetchSectionsList(
                      semesterId,
                      courseId
                  );

                  if (!dialogContext.mounted) return;

                  setState(() {
                    assessments = assessmentsList;
                    sections = sectionsList;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione un curso.';
                  }
                  return null;
                },
              ),
              SizedBox(height: SizeConfig.scaleHeight(2.3)),
              // Assessment dropdown
              CustomDropdownField<Assessment>(
                label: 'Evaluación',
                hintText: 'Seleccione una evaluación',
                value: selectedAssessment,
                items: assessments.where((a) => !usedIds.any((id) =>
                    id.assessmentId == a.id &&
                    id.sectionId == (selectedSection?.id ?? -1)
                )).toList(),
                itemLabel: (assessment) => '${assessment.type} ${assessment.number}',
                onChanged: (assessment) {
                  setState(() {
                    selectedAssessment = assessment;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione una evaluación.';
                  }
                  return null;
                },
              ),
              SizedBox(height: SizeConfig.scaleHeight(2.3)),
              // Section dropdown
              CustomDropdownField<Section>(
                label: 'Horario',
                hintText: 'Seleccione un horario',
                value: selectedSection,
                items: sections.where((s) => !usedIds.any((id) =>
                    id.sectionId == s.id &&
                    id.assessmentId == (selectedAssessment?.id ?? -1)
                )).toList(),
                itemLabel: (section) => section.name,
                onChanged: (section) {
                  setState(() {
                    selectedSection = section;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione un horario.';
                  }
                  return null;
                },
              ),
            ],
          ),
        );
      }
    ),
    onActionPressed: (BuildContext dialogContext) async {
      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        return false;
      }

      if (selectedSemester != null &&
          selectedCourse != null &&
          selectedAssessment != null &&
          selectedSection != null
      ) {
        final statsData = await onSelectionComplete({
          'semesterId': selectedSemester!.id,
          'courseId': selectedCourse!.id,
          'assessmentId': selectedAssessment!.id,
          'sectionId': selectedSection!.id,
        });

        if (statsData != null && statsData.containsKey('error')) {
          // An error occurred, do not close the dialog
          return false;
        }

        if (!dialogContext.mounted) return false;

        Navigator.of(dialogContext).pop();

        if (statsData == null) return false;

        final parentContext = dialogContext.findRootAncestorStateOfType<NavigatorState>()?.context
            ?? dialogContext;

        // Hide bottom bar just before entering the dashboard screen
        MainScreen.of(parentContext)?.setBottomBarVisibility(false);

        await Navigator.of(parentContext).push(
          MaterialPageRoute(
            builder: (_) => StatisticsDashboardScreen(
              initialStatsData: statsData['stats'] ?? {},
              semesterId: selectedSemester!.id,
              courseId: selectedCourse!.id,
              assessmentId: selectedAssessment!.id,
              sectionId: selectedSection!.id,
            ),
          ),
        );

        if (!parentContext.mounted) return false;

        // Restore bottom bar visibility when returning
        MainScreen.of(parentContext)?.setBottomBarVisibility(true);
      }

      return false;
    }
  );
}
