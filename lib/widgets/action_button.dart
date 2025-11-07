import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../theme/app_text_styles.dart';

enum ButtonLayout {
  vertical,
  horizontal,
}

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final ButtonLayout layout;
  final bool isOutlined;
  final double borderRadius;

  const ActionButton({
    super.key,
    this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.width,
    this.height,
    this.layout = ButtonLayout.vertical,
    this.isOutlined = false,
    this.borderRadius = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final Color foregroundColor;
    final Color containerColor;
    final Border? containerBorder;

    if (isOutlined) {
      foregroundColor = accentColor;
      containerColor = Colors.transparent;
      containerBorder = Border.all(
        color: accentColor,
        width: SizeConfig.scaleHeight(0.23),
        strokeAlign: BorderSide.strokeAlignInside,
      );
    } else {
      foregroundColor = AppColors.neutralLightLightest;
      containerColor = accentColor;
      containerBorder = null;
    }

    Widget? iconWidget;
    if (icon != null) {
      iconWidget = Icon(
        icon,
        size: SizeConfig.scaleHeight(3.75),
        fill: 1.0,
        color: foregroundColor,
      );
    }

    final labelWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: AppTextStyles.actionM().copyWith(
        color: foregroundColor,
      ),
    );

    final List<Widget> children = [];
    if (layout == ButtonLayout.vertical) {
      if (iconWidget != null) {
        children.add(iconWidget);
      }
      children.add(labelWidget);
    } else {
      if (iconWidget != null) {
        children.add(iconWidget);
        children.add(SizedBox(width: SizeConfig.scaleWidth(2.2)));
      }
      children.add(labelWidget);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(borderRadius)),
      onTap: onTap,
      child: Container(
        width: width ?? SizeConfig.scaleWidth(18),
        height: height ?? SizeConfig.scaleHeight(7),
        decoration: BoxDecoration(
          color: containerColor,
          border: containerBorder,
          borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(borderRadius)),
        ),
        child: Flex(
          direction: layout == ButtonLayout.vertical
              ? Axis.vertical
              : Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
