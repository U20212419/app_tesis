import 'package:flutter/material.dart';

class SearchFieldTheme extends ThemeExtension<SearchFieldTheme> {
  final Color? backgroundColor;
  final TextStyle? placeholderStyle;
  final TextStyle? inputTextStyle;

  const SearchFieldTheme({
    this.backgroundColor,
    this.placeholderStyle,
    this.inputTextStyle,
  });

  @override
  ThemeExtension<SearchFieldTheme> copyWith({
    Color? backgroundColor,
    TextStyle? placeholderStyle,
    TextStyle? inputTextStyle,
  }) {
    return SearchFieldTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      placeholderStyle: placeholderStyle ?? this.placeholderStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
    );
  }

  @override
  ThemeExtension<SearchFieldTheme> lerp(
      covariant ThemeExtension<SearchFieldTheme>? other, double t) {
    if (other is! SearchFieldTheme) {
      return this;
    }
    return SearchFieldTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      placeholderStyle: TextStyle.lerp(placeholderStyle, other.placeholderStyle, t),
      inputTextStyle: TextStyle.lerp(inputTextStyle, other.inputTextStyle, t),
    );
  }
}
