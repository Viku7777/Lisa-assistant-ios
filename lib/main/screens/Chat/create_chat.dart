import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/main/screens/Chat/chat_history.dart';
import 'package:lisa_ai/main/screens/Chat/chat_screen.dart';
import 'package:lisa_ai/main/screens/menu_screen.dart';

class CreateChatView extends StatefulWidget {
  const CreateChatView({super.key});

  static const String routeName = "/create_chat";

  @override
  State<CreateChatView> createState() => _CreateChatViewState();
}

class _CreateChatViewState extends State<CreateChatView> {
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
                Get.offAndToNamed(MenuScreen.routeName);
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
                onTap: () => Get.toNamed(ChatScreen.routeName),
                title: const Text(
                  "NEW CHAT",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: const Text(
                  "HISTORY",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.toNamed(ChatHistoryView.routeName);
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
