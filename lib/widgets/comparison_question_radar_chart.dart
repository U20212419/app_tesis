import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/statistics_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class ComparisonQuestionRadarChart extends StatelessWidget {
  final List<StatisticsData> statsDataList;
  final String? label;

  // Maximum number of questions to display in the chart
  final int maxQuestionAmount = 8;

  const ComparisonQuestionRadarChart({
    super.key,
    required this.statsDataList,
    this.label,
  });

  final List<Color> chartColors = const [
    AppColors.highlightMedium,
    AppColors.supportWarningMedium,
    AppColors.supportSuccessMedium,
    AppColors.supportErrorMedium,
  ];

  @override
  Widget build(BuildContext context) {
    if (statsDataList.isEmpty) {
      return Center(
        child: Text(
          "No hay datos para mostrar en el gráfico radar.",
          style: AppTextStyles.bodyM().copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    // Build radar data sets
    final List<RadarDataSet> dataSets = [];

    for (int i = 0; i < statsDataList.length; i++) {
      final statsData = statsDataList[i];
      final qStats = statsData.stats['statistics']?['question_stats'] ?? {};

      final values = List.generate(
        maxQuestionAmount,
        (i) {
          final questionKey = 'question_${i + 1}';
          final mean = qStats[questionKey]?['mean'];

          if (mean is num) {
            return mean.toDouble();
          } else {
            return 0.0;
          }
        },
      );

      dataSets.add(
        RadarDataSet(
          dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          borderColor: chartColors[i % chartColors.length],
          fillColor: chartColors[i % chartColors.length]
              .withValues(alpha: 0.3),
          entryRadius: 3,
          borderWidth: 2,
        ),
      );
    }

    // Labels
    final List<RadarChartTitle> radarTitles = List.generate(
      maxQuestionAmount,
      (index) => RadarChartTitle(
        text: "P${index + 1}",
      ),
    );

    return Container(
      height: SizeConfig.scaleHeight(50),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.scaleWidth(4.2),
        vertical: SizeConfig.scaleHeight(2.3),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          if (label != null)
              Text(
                label!,
                style: AppTextStyles.heading5().copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: SizeConfig.scaleHeight(3.2)),
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarBorderData: const BorderSide(
                  color: Colors.transparent,
                ),
                tickCount: 5,
                tickBorderData: BorderSide(color: theme.colorScheme.onSurfaceVariant),
                ticksTextStyle: AppTextStyles.bodyXS().copyWith(
                    color: theme.colorScheme.onSurface
                ),
                gridBorderData: BorderSide(color: theme.colorScheme.onSurface),
                radarShape: RadarShape.polygon,
                titlePositionPercentageOffset: 0.1,
                titleTextStyle: AppTextStyles.captionM().copyWith(
                    color: theme.colorScheme.onSurface
                ),
                getTitle: (index, angle) => radarTitles[index],
                dataSets: dataSets,
              ),
            ),
          ),
        ],
      ),
    );
  }
}