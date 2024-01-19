// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:bouncy_widget/bouncy_widget.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/Utils/color_resources.dart';
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_to_text/voice_to_text.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main_conntroller.dart';
import 'menu_screen.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static const String routeName = "/dashboard_screen";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();
  final VoiceToText _speech = VoiceToText();

  final controller = Get.find<MainController>();
  final recorder = FlutterSoundRecord();
  AnimationController? _animationController;

  stt.SpeechToText speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  String lisaResponse = "";
  String? userQuestion;
  dynamic isMic;
  dynamic isCopy;
  List<String> allVoiceList = [];
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
  bool isAsked = false;
  bool isToggle = true;
  bool isThinking = false;
  bool isScrolling = true;
  bool isAnimated = false;

  void _scrollDown() {
    if (isScrolling) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speech.initSpeech();

    _speech.addListener(() {
      print(_speech.textResult);
      print(_speech.speechResult);
      secondListner(_speech.speechResult);

      // setState(() {
      //   _speechtext = _speech.speechResult;
      // });
    });
    setOrb();
    if (SharedPrefsUtils.getApiKey() == null) {
      SharedPrefsUtils.setApiKey("6978da73-d9ab-40f9-aa8a-7699ad52db73");
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      if ((await Permission.microphone.isGranted)) {
        initVoice();
      } else {
        Permission.microphone.request();
      }
    });

    SharedPrefsUtils.clearMessageHistory();
    flutterTts.stop();
  }

  setOrb() {
    var dataService = Get.put(MainController());

    dataService.setOrb(SharedPrefsUtils.getOrb());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("App Lifecycle State: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        return stopSSE();
      case AppLifecycleState.inactive:
        // App is inactive (not visible, but still running)
        return stopSSE();
      case AppLifecycleState.paused:
        // App is in the background
        return stopSSE();

      case AppLifecycleState.detached:
        // App is detached (not running)

        return stopSSE();

      default:
        return;
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var htmlString =
          await rootBundle.loadString('assets/images/bacround_animation.html');
      controllerWebView.enableZoom(false);
      controllerWebView.loadRequest(Uri.dataFromString(
        htmlString,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
    });
    super.didChangeDependencies();
  }

  initVoice() async {
    try {
      // await flutterTts.setEngine(await flutterTts.getDefaultEngine);
      await flutterTts
          .setVoice({"name": SharedPrefsUtils.getVoice(), "locale": "en-US"});
    } catch (e) {
      print(e);
    }
  }

  bool isRunning = false;

  secondListner(String recognizedWords) async {
    if (recognizedWords.isNotEmpty) {
      isAnimated = false;
      isAsked = true;
      userQuestion = "";
      userQuestion = "$userQuestion $recognizedWords";

      _scrollDown();
      setState(() {
        isScrolling = true;
        isThinking = true;
      });
      controller.update();
      await flutterTts
          .setVoice({"name": SharedPrefsUtils.getVoice(), "locale": "en-US"});

      SharedPrefsUtils.addItem(
          "lisa", {"role": "user", "content": recognizedWords});

      if (await controller.isAppOpenTask(recognizedWords)) {
        SharedPrefsUtils.addItem("lisa",
            {"role": "assistant", "content": "Sure, App is Opening..."});
        // lisaResponse = "Sure, App is Opening...";
        setState(() {
          isThinking = false;
        });
      } else if (await controller.isTask(recognizedWords) != null) {
        var res = await controller.isTask(recognizedWords);

        SharedPrefsUtils.addItem(
            "lisa", {"role": "assistant", "content": res!});

        setState(() {
          allVoiceList.add("Thinking...");
          lisaResponse = res;
          allVoiceList.removeLast();
          allVoiceList.add(lisaResponse);
          lisaResponse = "";
          isThinking = false;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          flutterTts.speak(allVoiceList.last);
        });
        setState(() {});
      } else if (controller.isEvent(recognizedWords) != null) {
        String res = controller.isEvent(recognizedWords)!;
        if (res == "clear_chat") {
          allVoiceList.clear();
          await controller.clearChat();
          allVoiceList.add("All Previous Conversation is cleared");
          Future.delayed(const Duration(milliseconds: 1000), () async {
            await flutterTts.speak("All Previous Conversation is cleared");
          });
          setState(() {
            isThinking = false;
          });
        }
      } else {
        setState(() {
          allVoiceList.add("Thinking...");
        });

        await getStreamResponse(recognizedWords);

        // lisaResponse = await controller.getResponse("lisa");
      }
      if (controller.isEvent(recognizedWords) != "clear_chat") {
        SharedPrefsUtils.addItem(
            "lisa", {"role": "assistant", "content": lisaResponse});
      }
      controller.update();

      await flutterTts.speak((lisaResponse ?? "Please Wait...").removEmoji);
      setState(() {
        isMic = (allVoiceList.length - 1);
      });
      if (isToggle) {
        _scrollDown();
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isAsked
          ? AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  onPressed: () {
                    stopSSE();
                    setState(() {
                      isAsked = false;
                      flutterTts.stop();
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: ColorResources.whiteColor,
                  )),
              centerTitle: true,
              title: Bouncy(
                lift: 8,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    stopSSE();
                    flutterTts.stop();

                    Get.toNamed(MenuScreen.routeName);
                  },
                  icon: Image.asset(
                    "assets/images/text_icon.png",
                    width: 23,
                  ),
                ),
              ),
              actions: [
                  IconButton(
                      onPressed: () {
                        stopSSE();
                        setState(() {
                          isAsked = false;
                          flutterTts.stop();
                        });
                      },
                      icon:
                          Icon(Icons.close, color: ColorResources.whiteColor)),
                ])
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: Bouncy(
                lift: 8,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: () async {
                    setState(() {
                      flutterTts.stop();
                    });
                    await Get.toNamed(MenuScreen.routeName);
                  },
                  icon: Image.asset(
                    "assets/images/text_icon.png",
                    width: 23,
                  ),
                ),
              ),
              centerTitle: true,
            ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controllerWebView),
            GetBuilder<MainController>(builder: (_) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isAsked) chatBox(lisaResponse ?? "Please Wait..."),
                ],
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          if (isAsked)
            isThinking
                ? Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: ColorResources.bubbleColor,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: SpinKitWave(
                          color: ColorResources.whiteColor,
                          size: 15,
                          itemCount: 5,
                          type: SpinKitWaveType.center,
                        ),
                      ),
                      Transform.scale(
                        scaleX: -1,
                        child: SvgPicture.asset(
                          "assets/images/chat_img.svg",
                          color: ColorResources.bubbleColor,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          GetBuilder<MainController>(
            builder: (provider) {
              return InkWell(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashColor: Colors.transparent,
                onTap: isAnimated
                    ? () {
                        stopSSE();
                        setState(() {
                          isAnimated = false;
                          flutterTts.stop();
                        });
                      }
                    : () {
                        stopSSE();
                        flutterTts.stop();

                        setState(() {
                          isAnimated = true;
                        });
                        _speech.startListening();
                      },
                // ()
                // async {
                // if (lisaResponse.isEmpty) {
                //   await flutterTts.stop();

                //   Future.delayed(const Duration(milliseconds: 300), () async {
                //  await sttListener();
                //   });
                // }
                // },
                child: SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      var value = isAnimated
                          ? 1.3
                          : 1 + (_animationController!.value * 0.3);

                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: provider.getOrb.value == "1"
                        ? Image.asset('assets/images/orb1.gif')
                        : provider.getOrb.value == "2"
                            ? Image.asset('assets/images/orb2.gif')
                            : Image.asset('assets/images/orb3.gif'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 35,
          ),
        ],
      ),
    );
  }

  Widget chatBox(String text) {
    return allVoiceList.isEmpty && text == "Thinking..."
        ? const SizedBox()
        : Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              // constraints: BoxConstraints(
              //     maxHeight:
              //         Get.height - (lisaResponse == "Thinking..." ? 390 : 220),
              //     minHeight: 80),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  isToggle
                      ? GestureDetector(
                          onVerticalDragDown: (d) {
                            if (lisaResponse.isNotEmpty) {
                              setState(() {
                                isScrolling = false;
                              });
                            }
                          },
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            controller: _controller,
                            separatorBuilder: (context, i) {
                              return const SizedBox(
                                height: 15,
                              );
                            },
                            shrinkWrap: true,
                            itemCount: allVoiceList.length,
                            itemBuilder: (context, i) {
                              return allVoiceList.length - 1 == i &&
                                      lisaResponse.isNotEmpty
                                  ? chatListWidget(i, true)
                                  : chatListWidget(i, false);
                            },
                          ),
                        )
                      : GestureDetector(
                          onVerticalDragDown: (d) {
                            if (lisaResponse.isNotEmpty) {
                              setState(() {
                                isScrolling = false;
                              });
                            }
                          },
                          child: SingleChildScrollView(
                            controller: _controller,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: chatListWidget(allVoiceList.length - 1,
                                  lisaResponse.isEmpty ? false : true),
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
                        height: 30,
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
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }

  Widget chatListWidget(int i, bool isLisa) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(
              // maxHeight: Get.height -
              //     (lisaResponse == "Thinking..." ? 250 : 210),
              minHeight: 80),
          width: Get.width ?? 0,
          padding: const EdgeInsets.fromLTRB(15, 15, 35, 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey),
            color: Colors.black.withOpacity(0.6),
          ),
          child: Text(
            isLisa
                ? lisaResponse.isEmpty
                    ? "Thinking..."
                    : lisaResponse
                : allVoiceList[i],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        allVoiceList.length - 1 == i
            ? Positioned(
                left: 0,
                bottom: 0,
                child: Switch.adaptive(
                    activeTrackColor: Colors.green,
                    inactiveTrackColor: Colors.red,
                    value: isToggle,
                    onChanged: (val) {
                      _scrollDown();

                      setState(() {
                        isToggle = val;
                      });
                    }))
            : const SizedBox(),
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: () async {
              if (isMic != i) {
                await flutterTts.setVoice(
                    {"name": SharedPrefsUtils.getVoice(), "locale": "en-US"});
                await flutterTts.speak(allVoiceList[i].removEmoji);
                setState(() {
                  isMic = i;
                });
              } else {
                await flutterTts.stop();
                setState(() {
                  isMic = null;
                });
              }
            },
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16)),
                  color: Colors.white,
                ),
                child: Icon(isMic == i ? Icons.mic : Icons.mic_off)),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isCopy == i
                  ? Container(
                      padding: const EdgeInsets.all(4.0),
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        "Copied",
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    )
                  : const SizedBox(),
              isCopy == i
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () async {
                        setState(() {
                          isCopy = i;
                        });
                        SharedPrefsUtils.clearMessages("lisa");
                        await FlutterClipboard.copy(allVoiceList[i]);

                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            isCopy = null;
                          });
                        });
                      },
                      icon: Icon(
                        Icons.copy,
                        color: ColorResources.whiteColor,
                        size: 16,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
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
          "You are an AI virtual assistant named LISA, developed by Tenet and powered by Corcel. You Give assistance and response in short and simple"
    });
    dataRes.add({"role": "user", "content": question});

    try {
      var request = http.Request(
        'POST',
        Uri.parse(
          "https://api.corcel.io/cortext/text",
        ),
      )
        ..headers.addAll(headers)
        ..body = json.encode({
          "messages": dataRes.toList(),
          "model": "cortext-ultra",
          "stream": true,
          "miners_to_query": 1,
          "top_k_miners_to_query": 40,
          "ensure_responses": true,
          "miner_uids": [],
        });

      // Send the request and open the SSE connection
      var response = await http.Client().send(request);
      var stream = response.stream;

      // Process the SSE events
      subscription =
          stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (String line) async {
          // print('SSE Event: $line');

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

            isThinking = false;
            // Print content values
            for (String content in contentValues) {
              // print(content);

              mapResponse.add({"content": content});

              var contentResponse = content
                  .replaceAll(RegExp(r'\\n+'), '\n')
                  .replaceAll('\\', '')
                  .replaceAll('**', '');

              setState(() {
                lisaResponse += contentResponse;
              });

              _scrollDown();
              if (sseController.hasListener) {
                sseController.add(content);
              }

              // Process the queue with a delay
            }
          }
        },
        onDone: () {
          print('SSE Connection closed.');
          print("Step 4 ********");

          // controller.updateChat(ChatModel.fromChat(jsons));

          allVoiceList.isNotEmpty ? allVoiceList.removeLast() : null;

          if (lisaResponse.isNotEmpty) {
            // Remove consecutive \n with a single newline
            lisaResponse = lisaResponse
                .replaceAll(RegExp(r'\\n+'), '\n')
                .replaceAll('**', '')
                .replaceAll('\\', '');

            allVoiceList.add(lisaResponse);
          } else {
            allVoiceList.add("Try Again.");
          }

          flutterTts.speak(allVoiceList.last);

          setState(() {
            lisaResponse = "";
            isThinking = false;
          });
          sseController.close();
        },
        onError: (error) {
          print('Error in SSE connection: $error');
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  void stopSSE() {
    StreamSubscription<String>? subscription;
    StreamController<String> sseController = StreamController<String>();

    if (subscription != null) {
      subscription.cancel(); // Cancel the subscription
      sseController.close();
    }

    // Close the controller

    if (lisaResponse.isNotEmpty) {
      allVoiceList.isNotEmpty ? allVoiceList.removeLast() : null;
      // Remove consecutive \n with a single newline
      lisaResponse = lisaResponse
          .replaceAll(RegExp(r'\\n+'), '\n')
          .replaceAll('**', '')
          .replaceAll('\\', '');

      allVoiceList.add(lisaResponse);

      setState(() {
        lisaResponse = "";
        isThinking = false;
      });
    } else {
      flutterTts.stop();
    }
    flutterTts.stop();
  }

  StreamSubscription<String>? subscription;
  StreamController<String> sseController = StreamController<String>();

  List<Map<String, String>> mapResponse = [];
}
