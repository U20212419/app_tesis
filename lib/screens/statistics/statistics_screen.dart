import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../theme/app_text_styles.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_divider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final theme = Theme.of(context);

    return Scaffold(
        body: Column(
            children: [
              AppBar(
                  title: const Text('Visualización de Estadísticas'),
                  centerTitle: true,
              ),
              AppDivider(
                thickness: SizeConfig.scaleHeight(0.08),
              ),
              Expanded(
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
                    onTap: () {},
                    child: Container(
                      width: SizeConfig.scaleWidth(38),
                      height: SizeConfig.scaleHeight(11.2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1.9)),
                        border: Border.all(
                          color: theme.primaryColor,
                          width: SizeConfig.scaleHeight(0.23),
                          strokeAlign: BorderSide.strokeAlignInside,
                        )
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.add_2_rounded,
                            size: SizeConfig.scaleHeight(3.2),
                            fill: 1.0,
                            color: theme.primaryColor,
                          ),
                          Text(
                            "Añadir Evaluación",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.actionM().copyWith(
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ),
              ),
            ]
        )
    );
  }
}
