import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/custom_text_field_theme.dart';
import '../utils/size_config.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hintText;
  final TextStyle? hintStyle;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isOptional;
  final int errorMaxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.hintStyle,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.isOptional = false,
    this.errorMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final CustomTextFieldTheme? customTextFieldTheme = Theme.of(context).extension<CustomTextFieldTheme>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (label != null && label!.isNotEmpty)
              Text(
                label!,
                style: customTextFieldTheme?.fieldNameStyle ?? AppTextStyles.heading5().copyWith(
                  color: AppColors.neutralDarkDark,
                ),
              ),
              if (isOptional)
                Padding(
                  padding: EdgeInsets.only(left: SizeConfig.scaleWidth(0.5)),
                  child: Text(
                    '(opcional)',
                    style: customTextFieldTheme?.optionalLabelStyle ?? AppTextStyles.actionS().copyWith(
                      color: AppColors.neutralDarkLightest,
                    ),
                  ),
                )
          ],
        ),
        SizedBox(height: SizeConfig.scaleHeight(1.25)),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionHandleColor: Colors.transparent,
            ),
          ),
          child: TextFormField(
            controller: controller,
            cursorColor: AppColors.highlightDarkest,
            style: customTextFieldTheme?.inputTextStyle ?? AppTextStyles.bodyM().copyWith(
              color: AppColors.neutralDarkDarkest,
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: hintStyle ?? theme.inputDecorationTheme.hintStyle,
              errorMaxLines: errorMaxLines,
            ),
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ],
    );
  }
}
