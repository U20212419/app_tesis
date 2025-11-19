import 'package:app_tesis/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/statistics_data.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class ComparisonTotalScoreHistogramChart extends StatelessWidget {
  final List<StatisticsData> statsDataList;
  final String? label;

  // Define score ranges for histogram bins
  final List<String> ranges = const [
    '0-5',
    '6-10',
    '11-15',
    '16-20',
  ];

  int _getRangeIndex(num score) {
    if (score >= 0 && score <= 5) return 0;
    if (score >= 6 && score <= 10) return 1;
    if (score >= 11 && score <= 15) return 2;
    if (score >= 16 && score <= 20) return 3;
    return -1; // Out of range
  }

  const ComparisonTotalScoreHistogramChart({
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

  @override
  Widget build(BuildContext context) {
    final List<List<int>> histograms = [];

    // Build histograms for each assessment
    for (final stats in statsDataList) {
      final scoresList = (stats.stats['scores'] as List)
          .map((item) => (item['total_score'] as num).toDouble())
          .toList();

      final histogram = List<int>.filled(4, 0);

      for (final score in scoresList) {
        final index = _getRangeIndex(score);
        if (index != -1) {
          histogram[index]++;
        }
      }

      histograms.add(histogram);
    }

    // Generate bar groups for the chart
    final List<BarChartGroupData> barGroups = [];

    final double barWidth = 16 / (statsDataList.length * 0.5);

    for (int rangeIndex = 0; rangeIndex < 4; rangeIndex++) {
      final rods = <BarChartRodData>[];

      for (int evalIndex = 0; evalIndex < statsDataList.length; evalIndex++) {
        rods.add(
          BarChartRodData(
            toY: histograms[evalIndex][rangeIndex].toDouble(),
            width: barWidth,
            color: barColors[evalIndex % barColors.length],
            borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1)),
          ),
        );
      }

      barGroups.add(
        BarChartGroupData(
          x: rangeIndex,
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
                // maxY set to the highest frequency of a total score plus some padding
                maxY: histograms
                        .expand((hist) => hist)
                        .fold<double>(0.0, (max, value) => value > max ? value.toDouble() : max),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Text(
                            ranges[value.toInt()],
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
