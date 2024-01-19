// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Sql/sql_class.dart';
import 'package:lisa_ai/Utils/color_resources.dart';
import 'package:lisa_ai/Utils/helpers.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:lisa_ai/main/main_conntroller.dart';
import 'package:lisa_ai/main/models/chat_history_model.dart';
import 'package:lisa_ai/main/screens/Chat/chat_dashboard.dart';
import 'package:lisa_ai/main/screens/Chat/chat_screen.dart';
import 'package:lisa_ai/main/screens/Chat/read_chat_view.dart';
import 'package:readmore/readmore.dart';

class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({super.key});

  static const String routeName = "/chat_history";

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  var dataController = Get.find<MainController>();
  // List<String> list = [];
  List<ChatHistoryModel> allMessages = [];

  @override
  void initState() {
    refreshMessages();
    super.initState();
    // list = SharedPrefsUtils.getHistory();
    // list = list.reversed.toList();
  }

  // function to refresh Message list
  Future refreshMessages() async {
    var data = await SqlHelper.getchatItems();

    setState(() {
      allMessages = data
          .map((e) => ChatHistoryModel.fromHistory(
              jsonDecode(e['data']) as Map<String, dynamic>,
              e['id'].toString()))
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (_) {
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
        body: allMessages.isEmpty
            ? const Center(
                child: Text(
                  "History is Empty !!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.separated(
                controller: ScrollController(initialScrollOffset: 0.6),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                separatorBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 25),
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: ColorResources.whiteColor,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorResources.grayTransparent,
                          ColorResources.whiteColor,
                          ColorResources.grayTransparent,
                        ],
                      ),
                    ),
                  );
                },
                itemCount: allMessages.length,
                // reverse: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(ChatDashboard(
                        msg: allMessages[index].allChats,
                        id: int.parse(allMessages[index].ChatId),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: const BoxDecoration(
                          color: Colors.black54,
                          boxShadow: [
                            BoxShadow(blurRadius: 3, color: Colors.grey)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 5,
                            child: ReadMoreText(
                              allMessages[index].chatTitle.toString(),
                              style:
                                  TextStyle(color: ColorResources.whiteColor),
                              trimLines: 4,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: ' Read more',
                              moreStyle: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              callback: (value) {
                                Get.to(ReadMoreChatView(
                                  message: allMessages[index].chatTitle,
                                ));
                              },
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: IconButton(
                              onPressed: () async {
                                if (SharedPrefsUtils.getCurrentChatId() ==
                                    allMessages[index].ChatId) {
                                  _deleteItem(
                                      int.parse(allMessages[index].ChatId));
                                  dataController.deleteChat();
                                  await refreshMessages();

                                  if (allMessages.isNotEmpty) {
                                    SharedPrefsUtils.setCurrentChatId(
                                        allMessages.first.ChatId);
                                    dataController.setChatList(
                                        allMessages.first.allChats);
                                  } else {
                                    dataController.chatList.clear();
                                    SharedPrefsUtils.setCurrentChatId(
                                        "null".toString());
                                  }
                                } else {
                                  _deleteItem(
                                      int.parse(allMessages[index].ChatId));
                                }
                              },
                              icon: Icon(
                                Icons.delete,
                                color: ColorResources.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }

  void _deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    Helper.showMyToast("Message Deleted Successfully");
    // refreshMessages();
  }
}
