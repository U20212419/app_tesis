import 'package:app_tesis/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/statistics_data.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class ComparisonQuestionBarChart extends StatelessWidget {
  final Set<StatisticsData> statsDataList;
  final String? label;

  // Maximum number of questions to display in the chart
  final int maxQuestionAmount = 8;

  const ComparisonQuestionBarChart({
    super.key,
    required this.statsDataList,
    this.label,
  });

  final List<Color> barColors = const [
    AppColors.highlightMedium,
    AppColors.supportWarningMedium,
    AppColors.supportSuccessMedium,
    AppColors.supportErrorMedium,
  ];

  double findDynamicMaxY() {
    double maxY = 0.0;

    for (final statsData in statsDataList) {
      final aggStats = statsData.stats['statistics'] ?? {};
      final qStats = (aggStats['question_stats'] as Map<String, dynamic>?) ?? {};

      qStats.forEach((key, value) {
        final double qMax = (value['max'] as num?)?.toDouble() ?? 0.0;
        if (qMax > maxY) {
          maxY = qMax;
        }
      });
    }

    return maxY == 0 ? 1 : maxY; // Avoid zero maxY
  }

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];

    final double barWidth = 16 / (statsDataList.length * 0.5);

    for (int i = 0; i < maxQuestionAmount; i++) {
      final questionKey = 'question_${i + 1}';
      final List<BarChartRodData> rods = [];

      for (int j = 0; j < statsDataList.length; j++) {
        final statsData = statsDataList.elementAt(j);
        final aggStats = statsData.stats['statistics'] ?? {};
        final qStats = (aggStats['question_stats'] as Map<String, dynamic>?) ?? {};
        final qData = (qStats[questionKey] as Map<String, dynamic>?) ?? {};
        final double mean = (qData['mean'] as num?)?.toDouble() ?? 0.0;
        
        rods.add(
          BarChartRodData(
            toY: mean,
            width: barWidth,
            color: barColors[j % barColors.length],
            borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1)),
          ),
        );
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: rods,
        ),
      );
    }

    final theme = Theme.of(context);

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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: findDynamicMaxY(), // Max score per question
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                            'P${value.toInt() + 1}',
                            style: AppTextStyles.captionM().copyWith(
                                color: theme.colorScheme.onSurface
                            )
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                            '${value.toInt()}',
                            style: AppTextStyles.bodyXS().copyWith(
                                color: theme.colorScheme.onSurface
                            )
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
