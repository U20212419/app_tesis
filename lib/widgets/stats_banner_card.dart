import 'package:app_tesis/models/statistics_data.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class StatsBannerCard extends StatelessWidget {
  final StatisticsData statsData;
  final Color color;

  const StatsBannerCard({
    super.key,
    required this.statsData,
    this.color = AppColors.highlightDarkest,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> aggStats = statsData.stats['statistics'] ?? {};
    final int count = (aggStats['count'] as num?)?.toInt() ?? 0;
    final double mean = (aggStats['mean'] as num?)?.toDouble() ?? 0.0;
    final double median = (aggStats['median'] as num?)?.toDouble() ?? 0.0;
    final double stdDev = (aggStats['std_dev'] as num?)?.toDouble() ?? 0.0;
    final double min = (aggStats['min'] as num?)?.toDouble() ?? 0.0;
    final double max = (aggStats['max'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: EdgeInsets.fromLTRB(
        SizeConfig.scaleWidth(4.2),
        SizeConfig.scaleHeight(2.3),
        SizeConfig.scaleWidth(4.2),
        SizeConfig.scaleHeight(0),
      ),
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.scaleWidth(5.6),
          vertical: SizeConfig.scaleHeight(3.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas Generales',
              style: AppTextStyles.heading4().copyWith(
                  color: AppColors.neutralDarkDarkest,
              ),
            ),
            SizedBox(height: SizeConfig.scaleHeight(0.6)),
            Text(
              '${statsData.semesterName}\n${statsData.courseName}\n${statsData.assessmentName} | ${statsData.sectionName}',
              style: AppTextStyles.actionS().copyWith(
                  color: AppColors.neutralDarkLight,
              ),
            ),
            SizedBox(height: SizeConfig.scaleHeight(0.6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStatColumn(context, "Cantidad", count.toString())),
                Expanded(child: _buildStatColumn(context, "Media", mean.toStringAsFixed(2))),
                Expanded(child: _buildStatColumn(context, "Mediana", median.toStringAsFixed(2))),
              ],
            ),
            SizedBox(height: SizeConfig.scaleHeight(0.6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStatColumn(context, "Desv. Est.", stdDev.toStringAsFixed(2))),
                Expanded(child: _buildStatColumn(context, "Mínimo", min.toStringAsFixed(2))),
                Expanded(child: _buildStatColumn(context, "Máximo", max.toStringAsFixed(2))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyS().copyWith(
              color: AppColors.neutralDarkMedium
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyS().copyWith(
              color: AppColors.neutralDarkMedium
          ),
        ),
      ],
    );
  }
}
