import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lisa_ai/Utils/color_resources.dart';

class Helper {
  test() {}

  static Widget circularProgressBar({bool isLoading = true}) {
    return isLoading
        ? SizedBox(
            width: 20,
            child: SpinKitFadingCube(
              size: 20,
              color: ColorResources.primaryColor,
            ),
          )
        : const SizedBox.shrink();
  }

  static Widget linearProgressBar({bool isLoading = true}) {
    return isLoading
        ? const LinearProgressIndicator()
        : const SizedBox.shrink();
  }

  static int daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, date.day);
    var firstDayNextMonth = DateTime(firstDayThisMonth.year,
        firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  static deleteDialog(String title, {Function()? onDelete}) {
    AwesomeDialog(
      context: Get.context!,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      width: MediaQuery.of(Get.context!).size.width * .3,
      showCloseIcon: true,
      closeIcon: const Icon(Icons.close_fullscreen_outlined),
      title: 'Delete $title?',
      desc: 'Are you sure want to delete $title?',
      btnCancelOnPress: onDelete,
      btnOkText: "Cancel",
      btnCancelText: "Delete",
      onDismissCallback: (type) {},
      btnOkOnPress: () {},
    ).show();
  }

  static paymentDialog(String title, {Function()? onDelete}) {
    AwesomeDialog(
      context: Get.context!,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.topSlide,
      width: MediaQuery.of(Get.context!).size.width * .3,
      showCloseIcon: true,
      closeIcon: const Icon(Icons.close_fullscreen_outlined),
      title: 'Delete $title?',
      desc: 'Are you sure want to delete $title?',
      btnCancelOnPress: onDelete,
      btnOkText: "Cancel",
      btnCancelText: "Delete",
      onDismissCallback: (type) {},
      btnOkOnPress: () {},
    ).show();
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static void showMyToast(String msg, {int duration = 2}) {
    if (Get.context != null) {
      FlutterToastr.show(msg, Get.overlayContext!, duration: duration);
    } else {
      print('NUllllllllllllllllllllllllllll');
    }
  }

  static String? getFileExtension(String fileName) {
    try {
      return ".${fileName.split('.').last}";
    } catch (e) {
      return null;
    }
  }

  static String getFormattedTime(
    int timeMicro, {
    bool onlyDate = false,
    bool isSingleLine = false,
  }) {
    return DateFormat(
            'dd-MMM-yyyy${isSingleLine ? " " : "\n"}${onlyDate ? "" : "KK:mm:a"}')
        .format(DateTime.fromMicrosecondsSinceEpoch(timeMicro));
  }

  static AppBar appBarMy(String title,
      {isCenter = false, List<Widget>? actions}) {
    return AppBar(
      title: Text(title),
      centerTitle: isCenter,
      actions: actions,
    );
  }
}
