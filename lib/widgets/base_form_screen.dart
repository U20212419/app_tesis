import 'package:flutter/material.dart';
import 'package:app_tesis/widgets/secondary_bottom_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import 'action_button.dart';
import 'app_divider.dart';

class BaseFormScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  const BaseFormScreen({
    super.key,
    required this.title,
    required this.body,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            // Custom title
            title: Text(
              title,
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: const [],
          ),
          body: Column(
            children: [
              AppDivider(thickness: SizeConfig.scaleHeight(0.08)),
              Expanded(
                // Custom body content
                child: body,
              ),
            ],
          ),
          bottomNavigationBar: SecondaryBottomBar(
            actions: [
              ActionButton(
                icon: Symbols.cancel_rounded,
                label: 'Cancelar',
                accentColor: AppColors.highlightDarkest,
                // Custom cancel action
                onTap: onCancel ?? () => Navigator.pop(context),
                layout: ButtonLayout.horizontal,
              ),
              ActionButton(
                icon: Symbols.save_rounded,
                label: 'Guardar',
                accentColor: AppColors.highlightDarkest,
                // Custom save action
                onTap: onSave,
                layout: ButtonLayout.horizontal,
              ),
            ],
          ),
        ),

        if (isLoading)
          Container(
            color: AppColors.neutralDarkDarkest.withValues(alpha: 0.6),
            child: Center(
              child: const CircularProgressIndicator(
                color: AppColors.highlightDarkest,
              ),
            )
          ),
      ],
    );
  }
}
