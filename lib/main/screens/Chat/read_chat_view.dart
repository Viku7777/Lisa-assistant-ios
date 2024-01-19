import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/color_resources.dart';

class ReadMoreChatView extends StatefulWidget {
  String message;
  ReadMoreChatView({required this.message, super.key});

  @override
  State<ReadMoreChatView> createState() => _ReadMoreChatViewState();
}

class _ReadMoreChatViewState extends State<ReadMoreChatView> {
  bool copyIndex = false;
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: SingleChildScrollView(
              child: Text(
                widget.message,
                style: TextStyle(color: ColorResources.whiteColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    await FlutterClipboard.copy(widget.message);
                    setState(() {
                      copyIndex = true;
                    });

                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        copyIndex = false;
                      });
                    });
                  },
                  child: copyIndex
                      ? const Text(
                          "Copied",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        )
                      : Icon(
                          Icons.copy,
                          color: ColorResources.whiteColor,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
