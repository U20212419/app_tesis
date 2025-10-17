import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class BottomNavTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavTabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: SizeConfig.scaleHeight(3.75),
              fill: 1.0,
              color: isSelected
                  ? AppColors.highlightDarkest
                  : AppColors.neutralLightDark,
            ),
            SizedBox(height: SizeConfig.scaleHeight(1)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: isSelected
                  ? AppTextStyles.actionS().copyWith(
                color: AppColors.neutralDarkDarkest,
              )
                  : AppTextStyles.bodyXS().copyWith(
                color: AppColors.neutralDarkLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
