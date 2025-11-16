import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';
import 'action_button.dart';

Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required String title,
  required Widget body,
  required String actionButtonText,
  required FutureOr<bool> Function(BuildContext dialogContext) onActionPressed,
  required Color color,
  String cancelButtonText = 'Cancelar',
}) {
  return showDialog<T>(
    context: context,
    // Darken the background and prevent dismissal by tapping outside
    barrierDismissible: false,
    barrierColor: AppColors.neutralDarkDarkest.withValues(alpha: 0.6),
    builder: (BuildContext dialogContext) {
      return Theme(
        data: Theme.of(dialogContext).copyWith(
          // Cancel button
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(
                color: color,
                width: SizeConfig.scaleHeight(0.23),
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1.9)),
              ),
              padding: EdgeInsets.symmetric(vertical: SizeConfig.scaleHeight(1.9)),
            ),
          ),
          // Action button
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.neutralLightLightest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1.9)),
              ),
              padding: EdgeInsets.symmetric(vertical: SizeConfig.scaleHeight(1.5)),
            ),
          ),
        ),
        child: _CustomDialogView(
          title: title,
          body: body,
          actionButtonText: actionButtonText,
          onActionPressed: onActionPressed,
          color: color,
          cancelButtonText: cancelButtonText,
          dialogContext: dialogContext,
        ),
      );
    },
  );
}

class _CustomDialogView extends StatefulWidget {
  final String title;
  final Widget body;
  final String actionButtonText;
  final FutureOr<bool> Function(BuildContext dialogContext) onActionPressed;
  final Color color;
  final String cancelButtonText;
  final BuildContext dialogContext;

  const _CustomDialogView({
    required this.title,
    required this.body,
    required this.actionButtonText,
    required this.onActionPressed,
    required this.color,
    required this.cancelButtonText,
    required this.dialogContext,
  });

  @override
  State<_CustomDialogView> createState() => _CustomDialogViewState();
}

class _CustomDialogViewState extends State<_CustomDialogView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
        side: Theme.brightnessOf(context) == Brightness.light
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.primary,
                width: SizeConfig.scaleHeight(0.23),
                strokeAlign: BorderSide.strokeAlignInside,
              ),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: SizeConfig.scaleWidth(8.3)),
      child: Container(
        padding: EdgeInsets.all(SizeConfig.scaleWidth(4.4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: AppTextStyles.heading3().copyWith(color: widget.color),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.scaleHeight(1.25)),
            widget.body,
            SizedBox(height: SizeConfig.scaleHeight(4.4)),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: widget.cancelButtonText,
                    accentColor: widget.color,
                    isOutlined: true,
                    onTap: () => Navigator.of(context).pop(),
                    layout: ButtonLayout.horizontal,
                    width: SizeConfig.scaleWidth(36),
                    height: SizeConfig.scaleHeight(6.2),
                    borderRadius: 1.9,
                  ),
                ),
                SizedBox(width: SizeConfig.scaleWidth(2.2)),
                Expanded(
                  child: ActionButton(
                    label: widget.actionButtonText,
                    accentColor: widget.color,
                    onTap: () async {
                      final navigator = Navigator.of(context);

                      bool wasSuccessful = false;
                      try {
                        final FutureOr<bool> result =
                          widget.onActionPressed(widget.dialogContext);

                        if (result is Future<bool>) {
                          wasSuccessful = await result;
                        } else {
                          wasSuccessful = result;
                        }
                      } catch (e) {
                        wasSuccessful = false;
                      }

                      if (!mounted) return;

                      if (wasSuccessful) {
                        navigator.pop(true);
                      }
                    },
                    layout: ButtonLayout.horizontal,
                    width: SizeConfig.scaleWidth(36),
                    height: SizeConfig.scaleHeight(6.2),
                    borderRadius: 1.9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
