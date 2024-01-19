import 'package:flutter/material.dart';

class ColorResources {
  static Color primaryColor = const Color(0xFF6527BE);
  static Color secondaryColor = const Color(0xFFFFFFFF);
  static Color whiteColor = Colors.white;
  static const Color bgColor = Color(0xF5F5F5FF);
  static const Color lightRed = Color(0xC2F84040);
  static const Color gray = Color(0xff808080);
  static const Color grayTransparent = Color(0x2FABABAB);
  static const Color grayTransparent2 = Color(0xA3ABABAB);
  static const Color green = Color(0xff14CE7C);
  static const Color bubbleColor = Color(0xff262626);

  static LinearGradient linearGradient = const LinearGradient(colors: [
    Color(0xff7B7CCF),
    Color(0xff8973D9),
  ]);

  static LinearGradient blackShadowGradients = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black.withOpacity(0),
      Colors.black.withOpacity(0.1),
      Colors.black.withOpacity(0.2),
      Colors.black.withOpacity(0.3),
      Colors.black.withOpacity(0.4),
      Colors.black.withOpacity(0.5),
      Colors.black.withOpacity(0.6),
      Colors.black.withOpacity(0.7),
      Colors.black.withOpacity(0.8),
      Colors.black.withOpacity(0.9),
      Colors.black,
    ],
  );
}
