// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Sql/sql_class.dart';
import 'package:lisa_ai/Utils/color_resources.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:lisa_ai/main/models/chat_history_model.dart';
import 'package:lisa_ai/main/screens/Chat/create_chat.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../Utils/helpers.dart';
import '../../main_conntroller.dart';
import 'package:http/http.dart' as http;

class ChatDashboard extends StatefulWidget {
  List<ChatModel> msg;
  int id;
  ChatDashboard({required this.msg, this.id = 0, super.key});

  static const String routeName = "/create_chat_screen";

  @override
  State<ChatDashboard> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatDashboard> {
  final _textEditingController = TextEditingController();

  final controller = Get.find<MainController>();
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool isScrolling = true;
  String? responseText;
  String htmlString = "";
  String? key = Get.arguments;
  dynamic copyIndex;
  String questionResponse = "";
  List<Map<String, String>> mapResponse = [];

  final WebViewController controllerWebView = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );

  @override
  void initState() {
    super.initState();

    // controller.update();
    // WidgetsBinding.instance.addPostFrameCallback((_) => initData());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      htmlString =
          await rootBundle.loadString('assets/images/bacround_animation.html');
      controllerWebView.enableZoom(false);
      controllerWebView.loadRequest(Uri.dataFromString(
        htmlString,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
    });

    getPreviousMessage();
    _scrollDown();
  }

  Future<bool> rebuild() async {
    if (!mounted) return false;

    // if there's a current frame,
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return false;
    }

    setState(() {});
    return true;
  }

  getPreviousMessage() async {
    if (widget.msg.isNotEmpty) {
      // messageList = widget.msg;
      if (!await rebuild()) return;

      controller.setChatList(widget.msg);

      SharedPrefsUtils.setCurrentChatId(widget.id.toString());

      controller.update();
    } else {
      var db = await SqlHelper.getItem(
          int.parse(SharedPrefsUtils.getCurrentChatId()));

      var getData = jsonDecode(db[0]["data"]);

      controller.setChatList((getData["msgList"] as List)
          .map((e) => ChatModel.fromChat(e))
          .toList());
    }

    _scrollDown();
  }

  void _scrollDown() {
    if (isScrolling) {
      Future.delayed(const Duration(milliseconds: 500), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (_) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 70,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: IconButton(
            highlightColor: Colors.transparent,
            onPressed: () {
              Get.toNamed(CreateChatView.routeName);
            },
            icon: Image.asset(
              "assets/images/text_icon.png",
              width: 23,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.close,
                )),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controllerWebView),
            chatList(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border:
                  Border.all(color: Colors.white.withOpacity(0.6), width: 1.3),
            ),
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: TextField(
              style: TextStyle(color: ColorResources.whiteColor),
              controller: _textEditingController,
              decoration: InputDecoration(
                  hintText: "Ask me anything...",
                  hintStyle: const TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            String message = _textEditingController.text;
                            if (message.isEmpty) {
                              Helper.showMyToast("Write Prompt");
                              return;
                            }

                            Map<String, dynamic> json = {
                              "role": "user",
                              "content": message
                            };
                            controller.updateChat(ChatModel.fromChat(json));
                            _textEditingController.clear();
                            setState(() {
                              isScrolling = true;
                              isLoading = true;

                              controller.chatList.isEmpty
                                  ? null
                                  : _scrollDown();
                            });
                            controller.update();

                            await getStreamResponse(message);
                          },
                    icon: const Icon(Icons.send, color: Colors.white),
                  )),
            ),
          ),
        ),
      );
    });
  }

  // Add Message Item
  Future<void> _addMessageItem(String question, String message) async {
    var getData = await SqlHelper.getchatItems();
    await SqlHelper.updateItem(int.parse(SharedPrefsUtils.getCurrentChatId()),
        question, message, getData);
  }

  Future<void> getStreamResponse(String question) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream', // Set Accept header for SSE
      'Authorization': 'Bearer 9d3d9157-9554-4564-b965-55aed69f',
    };

    List<Map<String, String>> dataRes = mapResponse;
    dataRes.add({
      "role": "system",
      "content":
          "I am an AI virtual assistant named LISA, developed by Tenet and powered by Corcel"
    });

    dataRes.add({"role": "user", "content": question});
    try {
      var request =
          http.Request('POST', Uri.parse("https://api.corcel.io/cortext/text"))
            ..headers.addAll(headers)
            ..body = json.encode({
              "messages": dataRes.toList(),
              "model": "cortext-ultra",
              "stream": true,
              "miners_to_query": 1,
              "top_k_miners_to_query": 40,
              "ensure_responses": true,
              "miner_uids": [],
              "systemPrompt":
                  "I am an AI virtual assistant named LISA, developed by Tenet and powered by Corcel."
            });

      // Send the request and open the SSE connection
      var response = await http.Client().send(request);
      var stream = response.stream;
      controller.chatList.add(ChatModel("assistant", ""));
      // Process the SSE events
      stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
          (String line) {
        // Extract the content from the SSE event
        String keyword = 'data: ';
        if (line.contains(keyword)) {
          String content = line.split(keyword)[1].trim();

          String keywords = '"content": "';

          // Split the data into lines
          List<String> lines = content.split('\n');

          // Extract content values
          List<String> contentValues = lines
              .where((line) => line.contains(keywords))
              .map((line) => line.split(keywords).last.split('"').first)
              .toList();

          // Print content values
          for (String content in contentValues) {
            mapResponse.add({"content": content});
            setState(() {
              questionResponse += content
                  .replaceAll(RegExp(r'\\n+'), '\n')
                  .replaceAll('**', '')
                  .replaceAll('\\', '');
            });
            _scrollDown();
          }
        }
      }, onDone: () async {
        print('SSE Connection closed.');

        var streamResponse = questionResponse.isNotEmpty
            ? questionResponse
            : "Please Try Again !!";
        Map<String, dynamic> jsons = {
          "role": "assistant",
          "content": streamResponse
        };

        controller.chatList.removeLast();
        controller.updateChat(ChatModel.fromChat(jsons));

        await _addMessageItem(question, streamResponse);
        controller.update();

        questionResponse = "";

        setState(() {
          isLoading = false;
          _scrollDown();
        });
      }, onError: (error) {
        print('Error in SSE connection: $error');
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget chatList() {
    return Stack(
      children: [
        GestureDetector(
          onVerticalDragDown: (d) {
            if (questionResponse.isNotEmpty) {
              setState(() {
                isScrolling = false;
              });
            }
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.chatList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var message = controller.chatList.elementAt(index);

                    if (message.role == "assistant") {
                      return controller.chatList.length == index + 1 &&
                              isLoading
                          ? chatBox(questionResponse, index)
                          : chatBox(message.msg, index);
                    } else if (message.role == "user") {
                      return questionChatBox(message.msg);
                    } else {
                      return const Text("");
                    }
                  },
                ),
                isLoading && questionResponse.isEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     Expanded(child: questionChatBox(questionResponse)),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          color: ColorResources.bubbleColor,
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: SpinKitWave(
                                          color: ColorResources.whiteColor,
                                          size: 15,
                                          itemCount: 5,
                                          type: SpinKitWaveType.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 13,
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    left: 35,
                                    child: Transform.scale(
                                      scaleX: -1,
                                      child: SvgPicture.asset(
                                        "assets/images/chat_img.svg",
                                        color: ColorResources.bubbleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget chatBox(String text, int index) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 25,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: const Color.fromARGB(255, 36, 35, 35),
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await FlutterClipboard.copy(text);
                          setState(() {
                            copyIndex = index;
                          });

                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              copyIndex = null;
                            });
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10)),
                          child: copyIndex == index
                              ? const Text(
                                  "Copied",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13),
                                )
                              : const Text(
                                  "Copy",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 13),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 13,
            ),
          ],
        ),
        Positioned(
          left: 35,
          child: Transform.scale(
            scaleX: -1,
            child: SvgPicture.asset(
              "assets/images/chat_img.svg",
              color: ColorResources.bubbleColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget questionChatBox(String text) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: const Color(0xff008AFF),
                // gradient: ColorResources.linearGradient,
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 13,
            ),
          ],
        ),
        Positioned(
          right: 35,
          child: SvgPicture.asset(
            "assets/images/chat_img.svg",
            color: const Color(0xff008AFF),
          ),
        ),
      ],
    );
  }
}
