import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/helpers.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';

class CreateVoiceView extends StatefulWidget {
  const CreateVoiceView({super.key});

  static const String routeName = "/voice_screen";

  @override
  State<CreateVoiceView> createState() => _CreateVoiceViewState();
}

class _CreateVoiceViewState extends State<CreateVoiceView> {
  // FlutterTts flutterTts = FlutterTts();
  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
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
            onTap: () async {
              Helper.showMyToast("Voice Updated");
              // await SharedPrefsUtils.setVoice("en-us-x-iol-local");
              await SharedPrefsUtils.setVoice("Fred");

              Get.back();
            },
            title: const Text(
              "MR",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text(
              "MAN",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Helper.showMyToast("Voice Updated");
              await SharedPrefsUtils.setVoice("Aaron");

              Get.back();
              // var getVoice = await flutterTts.getVoices;
              // var english = getVoice.where((e) => e["locale"] == "en-US");
              // var coie = english.where((e) => e["gender"] == "male");
              // print(coie.map((e) => e));
            },
          ),
          ListTile(
            title: const Text(
              "MRS",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Helper.showMyToast("Voice Updated");
              await SharedPrefsUtils.setVoice("Nicky");

              Get.back();
            },
          ),
          ListTile(
            onTap: () async {
              Helper.showMyToast("Voice Updated");
              await SharedPrefsUtils.setVoice("Samantha");

              Get.back();
            },
            title: const Text(
              "MISS",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


  // var getVoice = await flutterTts.getVoices;
  //             var english = getVoice.where((e) => e["locale"] == "en-US");
  //             var coie = english.where((e) => e["gender"] == "female");
  //             print(coie.map((e) => e));