import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';
import 'app_divider.dart';

class SecondaryBottomBar extends StatelessWidget {
  final List<Widget> actions;
  final Color? backgroundColor;
  final double? height;
  final double spacingPercentage;

  final bool isModeActive;
  final String? modeTitle;
  final String? modeSubtitle;
  final Color? modeTitleColor;
  final VoidCallback? onCancelMode;

  const SecondaryBottomBar({
    super.key,
    required this.actions,
    this.backgroundColor,
    this.height,
    this.spacingPercentage = 4.2,
    this.isModeActive = false,
    this.modeTitle,
    this.modeSubtitle,
    this.modeTitleColor,
    this.onCancelMode,
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
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                ignoring: isModeActive,
                child: AnimatedOpacity(
                  opacity: isModeActive ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _buildActions(),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !isModeActive,
                child: AnimatedOpacity(
                  opacity: isModeActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: _buildModeBar(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    final spacingWidth = SizeConfig.scaleWidth(spacingPercentage);
    List<Widget> actionWidgets = [];
    for (int i = 0; i < actions.length; i++) {
      actionWidgets.add(actions[i]);
      if (i < actions.length - 1) {
        actionWidgets.add(SizedBox(width: spacingWidth));
      }
    }
    return actionWidgets;
  }

  Widget _buildModeBar(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              modeTitle ?? 'Modo Activo',
              style: AppTextStyles.heading3().copyWith(
                color: modeTitleColor ?? AppColors.neutralDarkDarkest,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: SizeConfig.scaleHeight(1.25)),
            Text(
              modeSubtitle ?? 'Seleccione un ítem',
              style: AppTextStyles.bodyS().copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: SizeConfig.scaleWidth(4.4),
            ),
            child: IconButton(
              icon: Icon(
                Symbols.cancel_rounded,
                size: SizeConfig.scaleHeight(4.7),
                fill: 1.0,
                color: modeTitleColor ?? AppColors.neutralDarkDarkest,
              ),
              onPressed: onCancelMode,
            ),
          ),
        ),
      ],
    );
  }
}
