import 'package:app_tesis/theme/app_text_styles.dart';
import 'package:app_tesis/widgets/action_button.dart';
import 'package:app_tesis/widgets/secondary_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/app_divider.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: const Text('Lista de Cursos'),
            centerTitle: true,
            titleTextStyle: AppTextStyles.heading4().copyWith(
              color: AppColors.neutralDarkDarkest,
            ),
            backgroundColor: AppColors.neutralLightLightest,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Symbols.search_rounded,
                  size: SizeConfig.scaleHeight(3.2),
                  fill: 1.0,
                  color: AppColors.highlightDarkest,
                ),
                onPressed: () {
                  // TODo: Search action
                },
              ),
              SizedBox(width: SizeConfig.scaleWidth(6.4)),
            ]
          ),
          AppDivider(
            thickness: SizeConfig.scaleHeight(0.08),
          ),
          Expanded(
              child: const Center(child: Text('Lista de cursos')),
          ),
          SecondaryBottomBar(
            actions: [
              ActionButton(
                icon: Symbols.add_2_rounded,
                label: 'Crear',
                backgroundColor: AppColors.highlightDarkest,
                onTap: () {},
              ),
              ActionButton(
                icon: Symbols.edit_rounded,
                label: 'Editar',
                backgroundColor: AppColors.highlightDarkest,
                onTap: () {},
              ),
              ActionButton(
                icon: Symbols.delete_forever_rounded,
                label: 'Eliminar',
                backgroundColor: AppColors.supportErrorDark,
                onTap: () {},
              ),
            ]
          )
        ]
      )
    );
  }
}
