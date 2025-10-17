import 'package:flutter/material.dart';

import '../utils/size_config.dart';

class AppTextStyles {
  // Heading
  static TextStyle heading1() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(3.75),
    fontWeight: FontWeight.w800, // extra bold
    letterSpacing: 0.24,
  );
  static TextStyle heading2() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.8),
    fontWeight: FontWeight.w800, // extra bold
    letterSpacing: 0.09,
  );
  static TextStyle heading3() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.5),
    fontWeight: FontWeight.w800, // extra bold
    letterSpacing: 0.08,
  );
  static TextStyle heading4() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.2),
    fontWeight: FontWeight.bold,
  );
  static TextStyle heading5() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(1.9),
    fontWeight: FontWeight.bold,
  );

  // Body
  static TextStyle bodyXL() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.8),
    fontWeight: FontWeight.w400, // normal
    height: 24/18,
  );
  static TextStyle bodyL() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.5),
    fontWeight: FontWeight.w400, // normal
    height: 22/16,
  );
  static TextStyle bodyM() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.2),
    fontWeight: FontWeight.w400, // normal
    height: 20/14,
  );
  static TextStyle bodyS() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(1.9),
    fontWeight: FontWeight.w400, // normal
    height: 16/12,
    letterSpacing: 0.12,
  );
  static TextStyle bodyXS() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(1.6),
    fontWeight: FontWeight.w400, // normal
    height: 14/10,
    letterSpacing: 0.15,
  );

  // Action
  static TextStyle actionL() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(2.2),
    fontWeight: FontWeight.w600, // semi bold
  );
  static TextStyle actionM() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(1.9),
    fontWeight: FontWeight.w600, // semi bold
  );
  static TextStyle actionS() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(1.6),
    fontWeight: FontWeight.w600, // semi bold
  );

  // Caption
  static TextStyle captionM() => TextStyle(
    fontFamily: 'Inter',
    fontSize: SizeConfig.scaleText(1.6),
    fontWeight: FontWeight.w600, // semi bold
    letterSpacing: 0.5,
  );
}