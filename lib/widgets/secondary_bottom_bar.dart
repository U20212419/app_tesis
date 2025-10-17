import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import 'app_divider.dart';

class SecondaryBottomBar extends StatelessWidget {
  final List<Widget> actions;
  final Color backgroundColor;
  final double? height;
  final double spacing;

  const SecondaryBottomBar({
    super.key,
    required this.actions,
    this.backgroundColor = AppColors.neutralLightLightest,
    this.height,
    this.spacing = 4.2,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppDivider(
            thickness: SizeConfig.scaleHeight(0.08)
        ),
        Container(
          width: double.infinity,
          height: height ?? SizeConfig.scaleHeight(9.2),
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: _buildActions(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    final spacingWidth = SizeConfig.scaleWidth(spacing);
    List<Widget> actionWidgets = [];
    for (int i = 0; i < actions.length; i++) {
      actionWidgets.add(actions[i]);
      if (i < actions.length - 1) {
        actionWidgets.add(SizedBox(width: spacingWidth));
      }
    }
    return actionWidgets;
  }
}
