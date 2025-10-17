import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../theme/app_text_styles.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
      onTap: onTap,
      child: Container(
        width: width ?? SizeConfig.scaleWidth(18),
        height: height ?? SizeConfig.scaleHeight(7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: SizeConfig.scaleHeight(3.75),
              fill: 1.0,
              color: AppColors.neutralLightLight,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.actionM().copyWith(
                color: AppColors.neutralLightLightest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
