import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main_conntroller.dart';

class Setting2Screen extends StatelessWidget {
  Setting2Screen({super.key});

  static const String routeName = "/setting2_screen";
  final controller = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (_) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          // appBar: AppBar(
          //   title: const Text(
          //     "Settings",
          //     textAlign: TextAlign.left,
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.w500,
          //         fontSize: 25),
          //   ),
          //   backgroundColor: Colors.transparent,
          //   elevation: 1,
          // ),
          body: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text(
                    "SETTINGS",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  ),
                ),
              ),
              // const Divider(color: Colors.white),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "SET API KEY",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.security_outlined,
                              color: Colors.white),
                          trailing:
                              Icon(Icons.info_outline, color: Colors.white),
                        ),
                        Divider(color: Colors.white38),
                        ListTile(
                          title: Text(
                            "GET API KEY",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.security_outlined,
                              color: Colors.white),
                          trailing:
                              Icon(Icons.info_outline, color: Colors.white),
                        ),
                        Divider(color: Colors.white38),
                        ListTile(
                          title: Text(
                            "VOICE",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.record_voice_over_outlined,
                              color: Colors.white),
                        ),
                        Divider(color: Colors.white38),
                        ListTile(
                          title: Text(
                            "ORB ANIMATION",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.animation_outlined,
                              color: Colors.white),
                        ),
                        Divider(color: Colors.white38),
                        ListTile(
                          title: Text(
                            "ABOUT US",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.info_outline_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),

              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 19),
                  child: Text(
                    "\"Help us out by lending your support through delegating on toastats\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        // fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                ),
              ),
              const Spacer(),
              Image.asset("assets/images/logo.png", width: 150),
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
