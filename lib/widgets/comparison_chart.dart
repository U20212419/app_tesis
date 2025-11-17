import 'package:app_tesis/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/statistics_data.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class ComparisonChart extends StatelessWidget {
  final List<StatisticsData> statsDataList;

  // Maximum number of questions to display in the chart
  final int maxQuestionAmount = 8;

  const ComparisonChart({
    super.key,
    required this.statsDataList,
  });

  final List<Color> barColors = const [
    AppColors.highlightLightest,
    AppColors.supportWarningLight,
    AppColors.supportSuccessLight,
    AppColors.supportErrorLight,
  ];

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];

    final double barWidth = 16 / (statsDataList.length * 0.5);

    for (int i = 0; i < maxQuestionAmount; i++) {
      final questionKey = 'question_${i + 1}';
      final List<BarChartRodData> rods = [];

      for (int j = 0; j < statsDataList.length; j++) {
        final statsData = statsDataList[j];
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

    return Container(
      height: SizeConfig.scaleHeight(50),
      padding: EdgeInsets.all(SizeConfig.scaleWidth(4.2)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20, // Max score per question
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text('P${value.toInt() + 1}', style: AppTextStyles.bodyXS());
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
