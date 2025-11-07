import 'package:flutter/material.dart';

class InfoCardTheme extends ThemeExtension<InfoCardTheme> {
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? iconColor;

  const InfoCardTheme({
    this.backgroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.iconColor,
  });

  @override
  ThemeExtension<InfoCardTheme> copyWith({
    Color? backgroundColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color? iconColor,
  }) {
    return InfoCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  @override
  ThemeExtension<InfoCardTheme> lerp(
      covariant ThemeExtension<InfoCardTheme>? other, double t) {
    if (other is! InfoCardTheme) {
      return this;
    }
    return InfoCardTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      subtitleStyle: TextStyle.lerp(subtitleStyle, other.subtitleStyle, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
    );
  }
}
