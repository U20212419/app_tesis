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
    final theme = Theme.of(context);
    final Color dividerDefaultColor = theme.dividerColor;
    return Center(
      child: Container(
        width: width ?? SizeConfig.screenWidth,
        height: thickness,
        color: color ?? dividerDefaultColor,
      ),
    );
  }
}
