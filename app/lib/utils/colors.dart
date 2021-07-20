import 'package:flutter/material.dart';

class ColorUtils {
  static const Color themeColor = const Color(0xff1c1d1f);
  static const Color themeDarkColor = const Color(0xff131415);
  static const Color themeLightColor = const Color(0xff333436);

  static const Color white = Colors.white;
  static const Color blue = const Color(0xff6590f1);
  static const Color blueLite = const Color(0x446590f1);
  static const Color green = const Color(0xff66be54);
  static const Color greenLite = const Color(0x4466be54);
  static const Color orange = const Color(0xfff57f16);
  static const Color orangeLite = const Color(0x44f57f16);
  static const Color grey = const Color(0xffa4a5a5);
  static const Color transparent = Colors.transparent;
  static const Color divider = const Color(0xff333436);
  static const Color textColor = Colors.white;
  static const Color textColorGrey = const Color(0xffd2d2d2);

  static Color getPasswordColor() {
    return blue;
  }

  static Color getPasswordBgColor() {
    return blueLite;
  }

  static Color getTextColor() {
    return green;
  }

  static Color getTextBgColor() {
    return greenLite;
  }

  static Color getTotpColor() {
    return orange;
  }

  static Color getTotpBgColor() {
    return orangeLite;
  }

  static Color getTagColor() {
    return const Color(0xFFFFFFFF);
  }

  static Color getTagBgColor() {
    return const Color(0x44FFFFFF);
  }
}
