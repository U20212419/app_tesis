import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/custom_text_field_theme.dart';
import '../utils/size_config.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String? label;
  final String hintText;
  final T? value;

  // List of items to display in the dropdown
  final List<T> items;

  // Function to get the label for each item
  final String Function(T item) itemLabel;

  // Callback when the value changes
  final FutureOr<void> Function(T? value)? onChanged;

  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    this.label,
    required this.hintText,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CustomTextFieldTheme? customTextFieldTheme =
        theme.extension<CustomTextFieldTheme>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: customTextFieldTheme?.fieldNameStyle ?? AppTextStyles.heading5().copyWith(
              color: AppColors.neutralDarkDark,
            ),
          ),
        SizedBox(height: SizeConfig.scaleHeight(1.25)),
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: theme.colorScheme.primary,
            highlightColor: theme.colorScheme.primary,
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            hint: Text(
              hintText,
              style: AppTextStyles.bodyXS().copyWith(
                color: theme.inputDecorationTheme.hintStyle?.color ??
                    AppColors.neutralDarkLightest,
              ),
            ),
            icon: Icon(
              Symbols.expand_more_rounded,
              size: SizeConfig.scaleHeight(3.1),
              color: theme.inputDecorationTheme.hintStyle?.color ??
                  AppColors.neutralDarkLightest,
            ),
            dropdownColor: theme.colorScheme.surface,
            elevation: 2,
            isExpanded: true,
            decoration: const InputDecoration(
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: customTextFieldTheme?.inputTextStyle ?? AppTextStyles.bodyM().copyWith(
              color: AppColors.neutralDarkDarkest,
            ),
          ),
        ),
      ],
    );
  }
}
