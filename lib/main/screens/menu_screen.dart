import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Sql/sql_class.dart';
import 'package:lisa_ai/main/screens/Chat/chat_dashboard.dart';
import 'package:lisa_ai/main/screens/Chat/create_chat.dart';
import 'package:lisa_ai/main/screens/Motion/motion_view.dart';
import 'package:lisa_ai/main/screens/note_screen.dart';
import 'package:lisa_ai/main/screens/vision_screen.dart';
import 'package:lisa_ai/main/screens/voice/voice_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Utils/helpers.dart';
import '../../Utils/sharedpref_utils.dart';
import '../main_conntroller.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  static const String routeName = "/menu_screen";
  final controller = Get.find<MainController>();
  bool isVoice = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (_) {
      return SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            Get.back(result: isVoice);
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              toolbarHeight: 70,
              leading: IconButton(
                  color: Colors.white,
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                    color: Colors.white,
                    onPressed: () async {
                      Get.back();
                    },
                    icon: const Icon(Icons.close)),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            bottomNavigationBar: Container(
              alignment: Alignment.topCenter,
              height: 60,
              child: Image.asset(
                "assets/images/logo.png",
                height: 40,
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  onTap: () => Get.back(),
                  title: const Text(
                    "TALK",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "CHAT",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    // var db = await SqlHelper.getchatItems();

                    // db.isNotEmpty
                    //     ? Get.toNamed(ChatDashboard.routeName)
                    //     :

                    Get.toNamed(CreateChatView.routeName);
                  },
                ),
                ListTile(
                  title: const Text(
                    "IMAGE",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await launchUrl(Uri.parse("https://studio.bitapai.io/"));
                  },
                ),
                ListTile(
                  title: const Text(
                    "ORB",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Get.toNamed(CreateMotionView.routeName),
                ),
                ListTile(
                  title: const Text(
                    "VOICE",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white, fontFamily: "SpaceMono"),
                  ),
                  onTap: () {
                    Get.toNamed(CreateVoiceView.routeName);
                    // voiceDialog();
                  },
                ),
                // ListTile(
                //   title: const Text(
                //     "NOTE",
                //     textAlign: TextAlign.center,
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   onTap: () {
                //     Get.toNamed(NoteScreenView.routeName);
                //   },
                // ),
                ListTile(
                  title: const Text(
                    "VISION",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Get.toNamed(VisionScreenView.routeName);
                  },
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  voiceDialog() {
    showDialog(
      context: Get.context!,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  child: const Text(
                    'VOICE 1',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onTap: () async {
                    Helper.showMyToast("Voice Updated");
                    await SharedPrefsUtils.setVoice("en-us-x-tpf-local");
                    isVoice = true;
                    Get.back();
                  },
                ),
                const SizedBox(height: 8.0),
                InkWell(
                  child: const Text(
                    'VOICE 2',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onTap: () async {
                    Helper.showMyToast("Voice Updated");
                    await SharedPrefsUtils.setVoice("en-us-x-sfg-local");
                    isVoice = true;
                    Get.back();
                  },
                ),
                const SizedBox(height: 8.0),
                InkWell(
                  child: const Text(
                    'VOICE 3',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onTap: () async {
                    Helper.showMyToast("Voice Updated");
                    await SharedPrefsUtils.setVoice("en-us-x-iob-local");
                    isVoice = true;
                    Get.back();
                  },
                ),
                const SizedBox(height: 8.0),
                InkWell(
                  child: const Text(
                    'VOICE 4',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onTap: () async {
                    Helper.showMyToast("Voice Updated");
                    await SharedPrefsUtils.setVoice("en-us-x-tpd-network");
                    isVoice = true;
                    Get.back();
                  },
                ),
                const SizedBox(height: 8.0),
                InkWell(
                  child: const Text(
                    'VOICE 5',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  onTap: () async {
                    Helper.showMyToast("Voice Updated");
                    await SharedPrefsUtils.setVoice("en-us-x-iol-local");
                    isVoice = true;
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
