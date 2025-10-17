import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockHorizontal;
  static late double blockVertical;
  static const double _designAspectRatio = 9 / 16; // Base aspect ratio

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    blockHorizontal = screenWidth / 100;
    blockVertical = screenHeight / 100;
  }

  // Scaling functions
  static double scaleHeight(double percentage) => blockVertical * percentage;
  static double scaleWidth(double percentage) {
    final currentAspectRatio = screenWidth / screenHeight;
    final correctionFactor = _designAspectRatio / currentAspectRatio;
    return blockHorizontal * percentage * correctionFactor;
  }
  static double scaleText(double percentage) => blockVertical * percentage;
}
