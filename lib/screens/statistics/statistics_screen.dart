import 'dart:developer';

import 'package:app_tesis/widgets/dashboard_add_assessment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../providers/statistics_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/custom_toast.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  void _onAddAssessment() async {
    showDashboardAddAssessmentDialog(
      context: context,
      onSelectionComplete: (selectedIds) async {
        final semesterId = selectedIds['semesterId']!;
        final courseId = selectedIds['courseId']!;
        final assessmentId = selectedIds['assessmentId']!;
        final sectionId = selectedIds['sectionId']!;

        if (!mounted) return null;

        log(
            "Selected IDs - Semester: $semesterId, Course: $courseId, Assessment: $assessmentId, Section: $sectionId");

        final statsProvider = Provider.of<StatisticsProvider>(
            context, listen: false);

        Map<String, dynamic>? statsData;

        try {
          statsData = await statsProvider.fetchStatistics(
            assessmentId,
            sectionId,
          );

          log("Fetched Stats Data: ${statsData?['stats'] ?? {}}");

          return statsData;
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
          return null;
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          AppBar(
              title: const Text('Dashboard'),
              centerTitle: true,
          ),
          AppDivider(
            thickness: SizeConfig.scaleHeight(0.08),
          ),
          Expanded(
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
                onTap: _onAddAssessment,
                child: Container(
                  width: SizeConfig.scaleWidth(38),
                  height: SizeConfig.scaleHeight(11.2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1.9)),
                    border: Border.all(
                      color: theme.primaryColor,
                      width: SizeConfig.scaleHeight(0.23),
                      strokeAlign: BorderSide.strokeAlignInside,
                    )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.add_2_rounded,
                        size: SizeConfig.scaleHeight(3.2),
                        fill: 1.0,
                        color: theme.primaryColor,
                      ),
                      Text(
                        "Añadir Evaluación",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.actionM().copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ),
          ),
        ]
      )
    );
  }
}
