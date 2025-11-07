import 'package:flutter/material.dart';
import 'package:app_tesis/widgets/secondary_bottom_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import 'action_button.dart';
import 'app_divider.dart';

class BaseCreationScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback onSave;
  final VoidCallback? onCancel;

  const BaseCreationScreen({
    super.key,
    required this.title,
    required this.body,
    required this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
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
            width: SizeConfig.scaleWidth(27.8),
            height: SizeConfig.scaleHeight(6.2),
            // Custom cancel action
            onTap: onCancel ?? () => Navigator.pop(context),
            layout: ButtonLayout.horizontal,
          ),
          ActionButton(
            icon: Symbols.save_rounded,
            label: 'Guardar',
            accentColor: AppColors.highlightDarkest,
            width: SizeConfig.scaleWidth(27.8),
            height: SizeConfig.scaleHeight(6.2),
            // Custom save action
            onTap: onSave,
            layout: ButtonLayout.horizontal,
          ),
        ],
      ),
    );
  }
}
