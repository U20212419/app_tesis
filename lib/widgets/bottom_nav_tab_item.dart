import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final TextStyle selectedTextStyle = AppTextStyles.actionS().copyWith(
      color: theme.colorScheme.onSurface,
    );
    final TextStyle unselectedTextStyle = AppTextStyles.bodyXS().copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

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
              color: isSelected ? theme.primaryColor : theme.dividerColor,
            ),
            SizedBox(height: SizeConfig.scaleHeight(1)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: isSelected ? selectedTextStyle : unselectedTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
