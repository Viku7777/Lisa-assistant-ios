import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Utils/color_resources.dart';
import '../Utils/sharedpref_utils.dart';

class ThemeController extends GetxController {
  Rx<Color> themeColor = ColorResources.primaryColor.obs;

  Color getThemeColor() {
    return SharedPrefsUtils.getThemeColor();
  }

  Future setThemeColor(Color color) async {
    await SharedPrefsUtils.setThemeColor(color);
    themeColor.value = color;
    update();

  }
}
