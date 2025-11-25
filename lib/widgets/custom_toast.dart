import 'dart:async';
import 'package:app_tesis/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';

enum CustomToastType {
  info,
  success,
  warning,
  error,
}

enum ToastPosition {
  top,
  bottom,
}

class CustomToast {
  static void show({
    required BuildContext context,
    required String title,
    required String detail,
    required CustomToastType type,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 4),
  }) {
    final GlobalKey<_ToastAnimatorState> animatorKey = GlobalKey();

    late OverlayEntry overlayEntry;

    bool isDismissed = false;

    // Close the toast
    void dismiss() async {
      // If the toast is already being dismissed, ignore further calls
      if (isDismissed) {
        return;
      }

      isDismissed = true;
      // Starts the exit animation before removing the overlay
      await animatorKey.currentState?.startExitAnimation();
      overlayEntry.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _ToastAnimator(
          key: animatorKey,
          position: position,
          onDismiss: dismiss,
          child: _CustomToastView(
            title: title,
            detail: detail,
            type: type,
            onDismiss: dismiss,
          ),
        );
      },
    );

    Timer(duration, dismiss);

    Overlay.of(context).insert(overlayEntry);
  }
}

class _ToastAnimator extends StatefulWidget {
  final Widget child;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const _ToastAnimator({
    super.key,
    required this.child,
    required this.position,
    required this.onDismiss,
  });

  @override
  _ToastAnimatorState createState() => _ToastAnimatorState();
}

class _ToastAnimatorState extends State<_ToastAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final beginOffset = widget.position == ToastPosition.top
        ? const Offset(0, -1.0)
        : const Offset(0, 1.0);

    _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic
      ),
    );

    _controller.forward();
  }

  Future<void> startExitAnimation() async {
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: widget.position == ToastPosition.top
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.scaleWidth(4.4),
            right: SizeConfig.scaleWidth(4.4),
            top: SizeConfig.scaleHeight(2.5),
            bottom: widget.position == ToastPosition.bottom
                ? SizeConfig.scaleHeight(10)
                : 0,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomToastView extends StatelessWidget {
  final String title;
  final String detail;
  final CustomToastType type;
  final VoidCallback onDismiss;

  const _CustomToastView({
    required this.title,
    required this.detail,
    required this.type,
    required this.onDismiss,
  });

  Map<String, dynamic> _getConfig(CustomToastType type) {
    switch (type) {
      case CustomToastType.info:
        return {
          'backgroundColor': AppColors.highlightLightest,
          'icon': Symbols.info_rounded,
          'iconColor': AppColors.highlightDarkest,
        };
      case CustomToastType.success:
        return {
          'backgroundColor': AppColors.supportSuccessLight,
          'icon': Symbols.check_circle_rounded,
          'iconColor': AppColors.supportSuccessMedium,
        };
      case CustomToastType.warning:
        return {
          'backgroundColor': AppColors.supportWarningLight,
          'icon': Icons.error_rounded,
          'iconColor': AppColors.supportWarningMedium,
        };
      case CustomToastType.error:
        return {
          'backgroundColor': AppColors.supportErrorLight,
          'icon': Symbols.cancel_rounded,
          'iconColor': AppColors.supportErrorMedium,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.scaleWidth(4.4),
          vertical: SizeConfig.scaleHeight(2.5),
        ),
        decoration: BoxDecoration(
          color: config['backgroundColor'] as Color,
          borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              config['icon'] as IconData,
              color: config['iconColor'] as Color,
              fill: 1.0,
              size: SizeConfig.scaleHeight(3.75),
            ),
            SizedBox(width: SizeConfig.scaleWidth(4.4)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading5().copyWith(
                      color: AppColors.neutralDarkDarkest,
                    ),
                  ),
                  SizedBox(height: SizeConfig.scaleHeight(0.6)),
                  Text(
                    detail,
                    style: AppTextStyles.bodyS().copyWith(
                      color: AppColors.neutralDarkMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: SizeConfig.scaleWidth(4.4)),
            InkWell(
              onTap: onDismiss,
              child: Icon(
                  Symbols.close_rounded,
                  size: SizeConfig.scaleHeight(3.1),
                  fill: 1.0,
                  color: AppColors.neutralDarkLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
