import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/info_card_theme.dart';
import '../utils/size_config.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final double? trailingIconSize;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailingIcon,
    this.trailingIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final InfoCardTheme? infoCardTheme = Theme.of(context).extension<InfoCardTheme>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: infoCardTheme?.backgroundColor ?? AppColors.neutralLightLight,
          borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.scaleWidth(4.4),
            vertical: SizeConfig.scaleHeight(2.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: infoCardTheme?.titleStyle ?? AppTextStyles.heading4().copyWith(
                        color: AppColors.neutralDarkDarkest,
                      ),
                      softWrap: true,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: SizeConfig.scaleHeight(0.6)),
                        child: Text(
                          subtitle!,
                          style: infoCardTheme?.subtitleStyle ?? AppTextStyles.bodyS().copyWith(
                            color: AppColors.neutralDarkLight,
                          ),
                          softWrap: true,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: SizeConfig.scaleWidth(4.4)),
                  child: Icon(
                    trailingIcon,
                    size: SizeConfig.scaleHeight(trailingIconSize ?? 1.9),
                    fill: 1.0,
                    color: infoCardTheme?.iconColor ?? AppColors.neutralDarkLightest,
                  )
                ),
            ],
          ),
        ),
      ),
    );
  }
}
