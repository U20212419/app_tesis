import 'dart:developer';

import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:app_tesis/widgets/dashboard_add_assessment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/assessment_section_id.dart';
import '../../models/statistics_data.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/section_provider.dart';
import '../../providers/semester_provider.dart';
import '../../providers/statistics_dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/comparison_chart.dart';
import '../../widgets/stats_banner_card.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> initialStatsData;
  final int semesterId;
  final int courseId;
  final int assessmentId;
  final int sectionId;

  const StatisticsDashboardScreen({
    super.key,
    required this.initialStatsData,
    required this.semesterId,
    required this.courseId,
    required this.assessmentId,
    required this.sectionId,
  });

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> {
  late StatisticsDashboardProvider _dashboardProvider;

  @override
  void initState() {
    super.initState();
    _dashboardProvider = Provider.of<StatisticsDashboardProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);

    final semester = await semesterProvider.fetchSemesterById(widget.semesterId);
    final course = await courseProvider.fetchCourseById(widget.courseId);
    final assessment = await assessmentProvider.fetchAssessmentById(widget.assessmentId);
    final section = await sectionProvider.fetchSectionById(widget.sectionId);

    if (!mounted) return;

    if (semester == null || course == null || assessment == null || section == null) {
      CustomToast.show(
        context: context,
        title: 'Error al cargar datos',
        detail: 'No se pudieron cargar los datos para el dashboard de estadísticas.',
        type: CustomToastType.error,
        position: ToastPosition.top,
      );
      return;
    }

    final initialData = StatisticsData(
      semesterName: '${semester.year}-${semester.number}',
      courseName: course.name,
      assessmentName: '${assessment.type} ${assessment.number}',
      sectionName: section.name,
      stats: widget.initialStatsData,
      id: AssessmentSectionId(
        assessmentId: widget.assessmentId,
        sectionId: widget.sectionId,
      ),
    );

    _dashboardProvider.addStats(initialData);
  }

  void _showAddAssessmentDialog() {
    final currentStatsCount = _dashboardProvider.statsList.length;

    if (currentStatsCount >= 4) {
      // Show a dialog indicating the maximum number of assessments has been reached
      CustomToast.show(
        context: context,
        title: 'Límite alcanzado',
        detail: 'No se pueden agregar más de 4 evaluaciones al panel de estadísticas.',
        type: CustomToastType.warning,
        position: ToastPosition.top,
      );
      return;
    }

    final usedIds = _dashboardProvider.statsList
        .map((data) => data.id)
        .toSet();

    showDashboardAddAssessmentDialog(
      context: context,
      onSelectionComplete: (selectedIds) async {
        final semesterId = selectedIds['semesterId']!;
        final courseId = selectedIds['courseId']!;
        final assessmentId = selectedIds['assessmentId']!;
        final sectionId = selectedIds['sectionId']!;

        try {
          await _dashboardProvider.fetchAndAddStats(
            context: context,
            semesterId: semesterId,
            courseId: courseId,
            assessmentId: assessmentId,
            sectionId: sectionId,
          );

          return null;
        } catch (e) {
          if (mounted) {
            final errorMessage = e.toString().replaceFirst("Exception: ", "");
            CustomToast.show(
              context: context,
              title: 'Error al obtener estadísticas',
              detail: errorMessage,
              type: CustomToastType.error,
              position: ToastPosition.top,
            );
          }
          return {'error': e.toString()};
        }
      },
      usedIds: usedIds,
    );
  }

  void _goBackToStatisticsSection() {
    _dashboardProvider.clearStats();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final statsList = context.watch<StatisticsDashboardProvider>().statsList;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          _goBackToStatisticsSection();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.scaleWidth(4.4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Symbols.arrow_back_rounded,
                      size: SizeConfig.scaleHeight(3.2),
                      fill: 1.0,
                      color: AppColors.highlightDarkest,
                    ),
                    onPressed: _goBackToStatisticsSection,
                  ),
                ),
              ),
              const Text('Dashboard'),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Symbols.download_rounded,
                        size: SizeConfig.scaleHeight(3.2),
                        fill: 1.0,
                        color: AppColors.highlightDarkest,
                      ),
                      onPressed: () {
                        // TODO: Implement export functionality
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: SizeConfig.scaleWidth(2.2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Symbols.add_2_rounded,
                          size: SizeConfig.scaleHeight(3.2),
                          fill: 1.0,
                          color: AppColors.highlightDarkest,
                        ),
                        onPressed: () {
                          _showAddAssessmentDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: const [],
        ),
        body: _buildDashboardBody(statsList),
      ),
    );
  }
}

Widget _buildDashboardBody(List<StatisticsData> statsList) {
  return Column(
    children: [
      AppDivider(thickness: SizeConfig.scaleHeight(0.08)),
      Expanded(
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.scaleWidth(4.2),
              vertical: SizeConfig.scaleHeight(2.3),
          ),
          children: [
            ...statsList.map((data) => StatsBannerCard(
              statsData: data,
              color: switch (statsList.indexOf(data) % 4) {
                0 => AppColors.highlightLightest,
                1 => AppColors.supportWarningLight,
                2 => AppColors.supportSuccessLight,
                _ => AppColors.supportErrorLight,
              },
            )),
            ComparisonChart(
              statsDataList: statsList,
            ),
            SizedBox(height: SizeConfig.scaleHeight(2.3)),
          ],
        ),
      ),
    ],
  );
}
