import 'package:app_tesis/theme/info_card_theme.dart';
import 'package:app_tesis/theme/search_field_theme.dart';
import 'package:flutter/material.dart';

import '../utils/size_config.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'custom_text_field_theme.dart';

class AppTheme {
  // Light mode
  static ThemeData lightTheme(BuildContext context) {
    final borderRadiusInputField = BorderRadius.circular(SizeConfig.scaleHeight(1.9));
    final borderWidthInputField = SizeConfig.scaleHeight(0.16);

    // Light mode borders for input fields
    final lightBaseBorder = OutlineInputBorder(
      borderRadius: borderRadiusInputField,
      borderSide: BorderSide(
          color: AppColors.neutralLightDarkest,
          width: borderWidthInputField
      ),
    );

    final lightFocusedBorder = OutlineInputBorder(
      borderRadius: borderRadiusInputField,
      borderSide: BorderSide(
          color: AppColors.highlightMedium,
          width: borderWidthInputField
      ),
    );

    final lightErrorBorder = OutlineInputBorder(
      borderRadius: borderRadiusInputField,
      borderSide: BorderSide(
          color: AppColors.supportErrorDark,
          width: borderWidthInputField
      ),
    );

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.highlightDarkest,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.highlightDarkest,
        brightness: Brightness.light,
        onSurface: AppColors.neutralDarkDarkest,
        onSurfaceVariant: AppColors.neutralDarkLight,
        surface: AppColors.neutralLightLightest,
        primary: AppColors.neutralLightLight,
      ),
      // Background
      scaffoldBackgroundColor: AppColors.neutralLightLightest,
      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutralLightLightest,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading4().copyWith(
          color: AppColors.neutralDarkDarkest,
        ),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
      ),
      // Divider
      dividerColor: AppColors.neutralLightDark,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyles.bodyS().copyWith(
          color: AppColors.neutralDarkLightest,
        ),
        errorStyle: AppTextStyles.bodyXS().copyWith(
            color: AppColors.supportErrorDark
        ),
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.scaleWidth(4.4),
          vertical: SizeConfig.scaleHeight(1.8),
        ),
        border: lightBaseBorder,
        enabledBorder: lightBaseBorder,
        focusedBorder: lightFocusedBorder,
        errorBorder: lightErrorBorder,
        focusedErrorBorder: lightErrorBorder,
      ),
      extensions: [
        InfoCardTheme(
          backgroundColor: AppColors.neutralLightLight,
          titleStyle: AppTextStyles.heading4().copyWith(
            color: AppColors.neutralDarkDarkest,
          ),
          subtitleStyle: AppTextStyles.bodyS().copyWith(
            color: AppColors.neutralDarkLight,
          ),
          iconColor: AppColors.neutralDarkLightest,
        ),
        SearchFieldTheme(
          backgroundColor: AppColors.neutralLightLight,
          placeholderStyle: AppTextStyles.bodyM().copyWith(
            color: AppColors.neutralDarkLightest,
          ),
          inputTextStyle: AppTextStyles.bodyM().copyWith(
            color: AppColors.neutralDarkDarkest,
          ),
        ),
        CustomTextFieldTheme(
          fieldNameStyle: AppTextStyles.heading5().copyWith(
            color: AppColors.neutralDarkDark,
          ),
          inputTextStyle: AppTextStyles.bodyM().copyWith(
            color: AppColors.neutralDarkDarkest,
          ),
        ),
      ],
    );
  }

  // Dark mode
  static ThemeData darkTheme(BuildContext context) {
    final borderRadiusInputField = BorderRadius.circular(SizeConfig.scaleHeight(1.9));
    final borderWidthInputField = SizeConfig.scaleHeight(0.16);

    // Dark mode borders for input fields
    final darkBaseBorder = OutlineInputBorder(
      borderRadius: borderRadiusInputField,
      borderSide: BorderSide(
          color: AppColors.neutralDarkDark,
          width: borderWidthInputField
      ),
    );

    final darkFocusedBorder = OutlineInputBorder(
      borderRadius: borderRadiusInputField,
      borderSide: BorderSide(
          color: AppColors.highlightMedium,
          width: borderWidthInputField
      ),
    );

    final darkErrorBorder = OutlineInputBorder(
      borderRadius: borderRadiusInputField,
      borderSide: BorderSide(
          color: AppColors.supportErrorDark,
          width: borderWidthInputField
      ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.highlightDarkest,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.highlightDarkest,
        brightness: Brightness.dark,
        onSurface: AppColors.neutralLightLightest,
        onSurfaceVariant: AppColors.neutralLightDark,
        surface: AppColors.neutralDarkDarkest,
        primary: AppColors.neutralDarkDark,
      ),
      // Background
      scaffoldBackgroundColor: AppColors.neutralDarkDarkest,
      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutralDarkDarkest,
        elevation: 0,
        titleTextStyle: AppTextStyles.heading4().copyWith(
          color: AppColors.neutralLightLightest,
        ),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
      ),
      // Divider
      dividerColor: AppColors.neutralDarkMedium,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyles.bodyS().copyWith(
          color: AppColors.neutralLightDarkest,
        ),
        errorStyle: AppTextStyles.bodyXS().copyWith(
            color: AppColors.supportErrorDark
        ),
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.scaleWidth(4.4),
          vertical: SizeConfig.scaleHeight(1.8),
        ),
        border: darkBaseBorder,
        enabledBorder: darkBaseBorder,
        focusedBorder: darkFocusedBorder,
        errorBorder: darkErrorBorder,
        focusedErrorBorder: darkErrorBorder,
      ),
      extensions: [
        InfoCardTheme(
          backgroundColor: AppColors.neutralDarkDark,
          titleStyle: AppTextStyles.heading4().copyWith(
            color: AppColors.neutralLightLightest,
          ),
          subtitleStyle: AppTextStyles.bodyS().copyWith(
            color: AppColors.neutralLightDark,
          ),
          iconColor: AppColors.neutralLightDarkest,
        ),
        SearchFieldTheme(
          backgroundColor: AppColors.neutralDarkDark,
          placeholderStyle: AppTextStyles.bodyM().copyWith(
            color: AppColors.neutralLightDarkest,
          ),
          inputTextStyle: AppTextStyles.bodyM().copyWith(
            color: AppColors.neutralLightLightest,
          ),
        ),
        CustomTextFieldTheme(
          fieldNameStyle: AppTextStyles.heading5().copyWith(
            color: AppColors.neutralLightLight,
          ),
          inputTextStyle: AppTextStyles.bodyM().copyWith(
            color: AppColors.neutralLightLightest,
          ),
        ),
      ],
    );
  }
}
