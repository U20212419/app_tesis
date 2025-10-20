import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/size_config.dart';

class AppTextStyles {
  // Heading
  static TextStyle heading1() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(3.75),
    fontWeight: FontWeight.w800, // extra bold
    letterSpacing: 0.24,
  );
  static TextStyle heading2() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.8),
    fontWeight: FontWeight.w800, // extra bold
    letterSpacing: 0.09,
  );
  static TextStyle heading3() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.5),
    fontWeight: FontWeight.w800, // extra bold
    letterSpacing: 0.08,
  );
  static TextStyle heading4() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.2),
    fontWeight: FontWeight.bold,
  );
  static TextStyle heading5() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(1.9),
    fontWeight: FontWeight.bold,
  );

  // Body
  static TextStyle bodyXL() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.8),
    fontWeight: FontWeight.w400, // normal
    height: 24/18,
  );
  static TextStyle bodyL() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.5),
    fontWeight: FontWeight.w400, // normal
    height: 22/16,
  );
  static TextStyle bodyM() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.2),
    fontWeight: FontWeight.w400, // normal
    height: 20/14,
  );
  static TextStyle bodyS() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(1.9),
    fontWeight: FontWeight.w400, // normal
    height: 16/12,
    letterSpacing: 0.12,
  );
  static TextStyle bodyXS() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(1.6),
    fontWeight: FontWeight.w400, // normal
    height: 14/10,
    letterSpacing: 0.15,
  );

  // Action
  static TextStyle actionL() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(2.2),
    fontWeight: FontWeight.w600, // semi bold
  );
  static TextStyle actionM() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(1.9),
    fontWeight: FontWeight.w600, // semi bold
  );
  static TextStyle actionS() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(1.6),
    fontWeight: FontWeight.w600, // semi bold
  );

  // Caption
  static TextStyle captionM() => GoogleFonts.inter(
    fontSize: SizeConfig.scaleText(1.6),
    fontWeight: FontWeight.w600, // semi bold
    letterSpacing: 0.5,
  );
}