import 'package:app_tesis/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../utils/size_config.dart';

class AppDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double? width;

  const AppDivider({
    super.key,
    this.thickness = 0.5,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width ?? SizeConfig.screenWidth,
        height: thickness,
        color: color ?? AppColors.neutralLightDark,
      ),
    );
  }
}
