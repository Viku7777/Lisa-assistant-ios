import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/helpers.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:lisa_ai/main/main_conntroller.dart';

class CreateMotionView extends StatefulWidget {
  const CreateMotionView({super.key});

  static const String routeName = "/create_motion";

  @override
  State<CreateMotionView> createState() => _CreateMotionViewState();
}

class _CreateMotionViewState extends State<CreateMotionView> {
  @override
  Widget build(BuildContext context) {
    var dataServices = Get.find<MainController>();
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
          Column(
            children: [
              ListTile(
                onTap: () async {
                  dataServices.setOrb("1");
                  await SharedPrefsUtils.setOrb("1");
                  Get.back();
                  Helper.showMyToast("Motion Updated");
                },
                title: const Text(
                  "NOVA",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: const Text(
                  "AURORA",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  dataServices.setOrb("2");
                  await SharedPrefsUtils.setOrb("2");
                  Get.back();
                  Helper.showMyToast("Motion Updated");
                },
              ),
              ListTile(
                title: const Text(
                  "SHIMER",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  dataServices.setOrb("3");
                  await SharedPrefsUtils.setOrb("3");
                  Get.back();
                  Helper.showMyToast("Motion Updated");
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          )
        ],
      ),
    );
  }
}
