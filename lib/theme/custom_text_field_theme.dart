import 'package:flutter/material.dart';

class CustomTextFieldTheme extends ThemeExtension<CustomTextFieldTheme> {
  final TextStyle? fieldNameStyle;
  final TextStyle? inputTextStyle;
  final TextStyle? optionalLabelStyle;

  const CustomTextFieldTheme({
    this.fieldNameStyle,
    this.inputTextStyle,
    this.optionalLabelStyle,
  });

  @override
  ThemeExtension<CustomTextFieldTheme> copyWith({
    TextStyle? fieldNameStyle,
    TextStyle? inputTextStyle,
    TextStyle? optionalLabelStyle,
  }) {
    return CustomTextFieldTheme(
      fieldNameStyle: fieldNameStyle ?? this.fieldNameStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      optionalLabelStyle: optionalLabelStyle ?? this.optionalLabelStyle,
    );
  }

  @override
  ThemeExtension<CustomTextFieldTheme> lerp(
      covariant ThemeExtension<CustomTextFieldTheme>? other, double t) {
    if (other is! CustomTextFieldTheme) {
      return this;
    }
    return CustomTextFieldTheme(
      fieldNameStyle: TextStyle.lerp(fieldNameStyle, other.fieldNameStyle, t),
      inputTextStyle: TextStyle.lerp(inputTextStyle, other.inputTextStyle, t),
      optionalLabelStyle: TextStyle.lerp(optionalLabelStyle, other.optionalLabelStyle, t),
    );
  }
}
