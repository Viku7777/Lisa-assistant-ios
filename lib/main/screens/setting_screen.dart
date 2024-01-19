import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/my_dialog.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/helpers.dart';
import '../main_conntroller.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  static const String routeName = "/setting_screen";
  final controller = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (_) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            // title: const Text(
            //   "Settings",
            //   textAlign: TextAlign.left,
            //   style: TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.w500,
            //       fontSize: 25),
            // ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const Text(""),
            actions: [
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.close)),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              // Card(
              //   color: Colors.black,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(15.0),
              //   ),
              //   child: const Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              //     child: Text(
              //       "SETTINGS",
              //       textAlign: TextAlign.left,
              //       style: TextStyle(
              //           color: Colors.white,
              //           fontWeight: FontWeight.w500,
              //           fontSize: 30),
              //     ),
              //   ),
              // ),
              // const Divider(color: Colors.white),
              const SizedBox(
                height: 10,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          "GET API",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          await launchUrl(Uri.parse("https://bitapai.io/"));

                        },
                        // leading: Icon(Icons.security_outlined,
                        //     color: Colors.white),
                        // trailing:
                        //     Icon(Icons.info_outline, color: Colors.white),
                      ),
                      ListTile(
                        title: const Text(
                          textAlign: TextAlign.center,
                          "SET API",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          MyDialog.showApiKeyDialog(context, controller);
                        },
                        // leading: Icon(Icons.security_outlined,
                        //     color: Colors.white),
                        // trailing:
                        //     Icon(Icons.info_outline, color: Colors.white),
                      ),
                      const ListTile(
                        title: Text(
                          textAlign: TextAlign.center,
                          "VOICE",
                          style: TextStyle(color: Colors.white),
                        ),
                        // leading: Icon(Icons.record_voice_over_outlined,
                        //     color: Colors.white),
                      ),
                      ListTile(
                        title: const Text(
                          textAlign: TextAlign.center,
                          "ORB ANIMATION",
                          style: TextStyle(color: Colors.white),
                        ),
                        // leading: Icon(Icons.animation_outlined,
                        //     color: Colors.white),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: Colors.black,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(28.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        child: const Text(
                                          'ORB 1',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white),
                                        ),
                                        onTap: () async {
                                          Helper.showMyToast("Orb Updated");
                                          await SharedPrefsUtils.setOrb("1");
                                          controller.update();
                                          Get.back();
                                        },
                                      ),
                                      const SizedBox(height: 8.0),
                                      InkWell(
                                        child: const Text(
                                          'ORB 2',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white),
                                        ),
                                        onTap: () async {
                                          Helper.showMyToast("Orb Updated");
                                          await SharedPrefsUtils.setOrb("2");
                                          controller.update();
                                          Get.back();
                                        },
                                      ),
                                      const SizedBox(height: 8.0),
                                      InkWell(
                                        child: const Text(
                                          'ORB 3',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white),
                                        ),
                                        onTap: () async {
                                          await SharedPrefsUtils.setOrb("3");
                                          controller.update();
                                          Helper.showMyToast("Orb Updated");
                                          Get.back();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Spacer(),

              Image.asset('assets/images/logo.png', width: 100),

              // Spacer(),
              // Image.asset("assets/images/logo.png", width: 150),
              // const Text(
              //   "Version 1.0",
              //   style: TextStyle(color: Colors.white38),
              // ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      );
    });
  }
}
