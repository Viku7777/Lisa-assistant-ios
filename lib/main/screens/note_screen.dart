import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/color_resources.dart';

class NoteScreenView extends StatefulWidget {
  static const String routeName = "/note";

  const NoteScreenView({super.key});

  @override
  State<NoteScreenView> createState() => _NoteScreenViewState();
}

class _NoteScreenViewState extends State<NoteScreenView> {
  bool isCopy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.close, color: ColorResources.whiteColor)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        height: Get.height,
        width: Get.width,
        color: Colors.black,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text.rich(
                TextSpan(
                  text: '“',
                  style: TextStyle(
                    fontSize: 25.0,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      //set default font
                      style: TextStyle(
                          // fontFamily: 'SpaceMono',
                          color: Colors.white,
                          fontSize: 17,
                          // fontWeight: FontWeight.w600,
                          height: 4),
                      text:
                          'This App Is Free For You To Use. If You Like It, You Can Support Us By Delegating To Taostats & Corcel Validator.',
                    ),
                    TextSpan(
                      text: '”',
                      style: TextStyle(
                        fontSize: 25.0,
                        // fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20),
        alignment: Alignment.topCenter,
        height: 60,
        child: Image.asset(
          "assets/images/logo.png",
          height: 40,
        ),
      ),
    );
  }
}
