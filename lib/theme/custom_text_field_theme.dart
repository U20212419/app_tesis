import 'package:flutter/material.dart';

class CustomTextFieldTheme extends ThemeExtension<CustomTextFieldTheme> {
  final TextStyle? fieldNameStyle;
  final TextStyle? inputTextStyle;

  const CustomTextFieldTheme({
    this.fieldNameStyle,
    this.inputTextStyle,
  });

  @override
  ThemeExtension<CustomTextFieldTheme> copyWith({
    TextStyle? fieldNameStyle,
    TextStyle? inputTextStyle,
  }) {
    return CustomTextFieldTheme(
      fieldNameStyle: fieldNameStyle ?? this.fieldNameStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
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
    );
  }
}
