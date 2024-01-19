// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lisa_ai/Utils/sharedpref_utils.dart';
import 'package:lisa_ai/main/models/chat_history_model.dart';

import '../Utils/helpers.dart';

class MainController extends GetxController {
  Future<String> getStreamResponse(String question) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream', // Set Accept header for SSE
      'Authorization': 'Bearer 9d3d9157-9554-4564-b965-55aed69f',
    };

    try {
      String responseData = "";
      var request =
          http.Request('POST', Uri.parse("https://api.corcel.io/cortext/text"))
            ..headers.addAll(headers)
            ..body = json.encode({
              "messages": [
                {"role": "user", "content": question}
              ],
              "model": "cortext-ultra",
              "stream": true,
              "miners_to_query": 1,
              "top_k_miners_to_query": 40,
              "ensure_responses": false
            });

      // Send the request and open the SSE connection
      var response = await http.Client().send(request);
      var stream = response.stream;

      // Process the SSE events
      stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
        (String line) {
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

            // Print content values
            for (String content in contentValues) {
              updateResponse(content);
              responseData += content;
            }

            print("Step My ******* ");
          }
        },
        onDone: () {
          print('SSE Connection closed.');
        },
        onError: (error) {
          print('Error in SSE connection: $error');
        },
      );
      return responseData;
    } catch (e) {
      print('Error: $e');
      return "";
    }
  }

  // Future<String?> getResponse(String key) async {
  //   var headers = {
  //     'Content-Type': 'application/json',
  //     'X-API-KEY': SharedPrefsUtils.getApiKey()!
  //   };
  //   var request =
  //       http.Request('POST', Uri.parse('https://api.bitapai.io/cortext'));
  //   var list = (SharedPrefsUtils.getMessages(key));
  //   print('  List $list');
  //   request.body = json.encode({
  //     "messages": list,
  //     // "pool_id": 4,
  //     // "uids": [387, 158, 40, 410, 187, 500, 846],
  //     "count": 10,
  //     "return_all": false
  //   });
  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();
  //   print("Status code checker ******************************");
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     var result = await response.stream.bytesToString();

  //     if (((jsonDecode(result)["choices"]) as List).isNotEmpty) {
  //       String text = jsonDecode(result)["choices"][0]["message"]["content"];

  //       return text;
  //     } else {
  //       return await getResponse(key);
  //     }
  //   } else {
  //     print(await response.stream.bytesToString());
  //     return null;
  //   }
  // }

  addEvent(String text, String time) async {
    DateTime dateTime = DateTime.parse(time);
    final Event event = Event(
      title: 'Lisa Reminder',
      description: text,
      startDate: dateTime.subtract(const Duration(minutes: 5)),
      endDate: dateTime,
    );

    await Add2Calendar.addEvent2Cal(event);
  }

  Future<String?> getName(var message) async {
    print(
        "Api Key Checker ::::::::::::::::::::::::::: ${SharedPrefsUtils.getApiKey()}");
    var headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': SharedPrefsUtils.getApiKey()!
    };
    var request =
        http.Request('POST', Uri.parse('https://api.bitapai.io/cortext'));

    request.body = json.encode({
      "messages": [
        {"role": "system", "content": introText},
        // {"role": "user", "content": message},
        {
          "role": "user",
          "content":
              "give me title name for this '$message', according to topic, in just only 2 words. 'just return title in response in 2 words'."
        }
      ],
      // "uids": [387, 158, 40, 410, 187, 500, 846],
      "count": 10,
      "return_all": false
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();

      print("Result Checker ;;;;;$result");
      if (jsonDecode(result)["choices"].isEmpty) {
        return getWordsFromString(message);
      } else {
        String text = jsonDecode(result)["choices"][0]["message"]["content"];
        return text;
      }
    } else {
      print(await response.stream.bytesToString());
      return null;
    }
  }

  String getWordsFromString(String inputString) {
    // Split the input string into words
    List<String> words = inputString.split(' ');

    if (words.length >= 2) {
      // If there are two or more words, return the first two words
      return '${words[0]} ${words[1]} ${Helper.getFormattedTime(DateTime.now().microsecondsSinceEpoch, isSingleLine: true)}';
    } else if (words.length == 1) {
      // If there's only one word, return that word
      return "${words[0]} ${Helper.getFormattedTime(DateTime.now().microsecondsSinceEpoch, isSingleLine: true)}";
    } else {
      // Handle the case where there are no words or empty input
      return "$inputString ${Helper.getFormattedTime(DateTime.now().microsecondsSinceEpoch, isSingleLine: true)}";
    }
  }

  Future<bool> isApiKeyCorrect(String apiKey) async {
    var headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': apiKey.trim()
    };
    var request =
        http.Request('POST', Uri.parse('https://api.bitapai.io/cortext'));

    request.body = json.encode({
      "messages": [
        {"role": "system", "content": introText},
        {"role": "user", "content": "Hi"}
      ],
      // "uids": [387, 158, 40, 410, 187, 500, 846],
      "count": 10,
      "return_all": false
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      Helper.showMyToast("Api Key Set Successfully");

      return true;
    } else {
      var result = await response.stream.bytesToString();
      String? text = jsonDecode(result)["error"];
      Helper.showMyToast(text ?? result);
      return false;
    }
  }

  Future<String?> getTimeFromPrompt(String prompt) async {
    print('Promt in time date XXX : $prompt');
    // String timeGetPrompt =
    //     "User will give a text with time and date, You have to tell time in this format '${DateTime.now().toIso8601String()}' and now current date time is '${DateTime.now().toIso8601String()}', and answer must be in 16 characters.";
    String timeGetPrompt =
        "Extract the date and time from user input and return in this format : '${DateTime.now().toIso8601String()}', and answer must be in 16 characters. current date time is ${DateTime.now().toIso8601String()}";
    var headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': SharedPrefsUtils.getApiKey()!
    };
    var request =
        http.Request('POST', Uri.parse('https://api.bitapai.io/cortext'));

    request.body = json.encode({
      "messages": [
        {"role": "system", "content": timeGetPrompt},
        {
          "role": "user",
          "content": prompt,
        }
      ],
      // "uids": [387, 158, 40, 410, 187, 500, 846],
      "count": 10,
      "return_all": false
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      String text = jsonDecode(result)["choices"][0]["message"]["content"];
      print('Time Response $text');
      return extractTime(text);
    } else {
      var result = await response.stream.bytesToString();
      String? text = jsonDecode(result)["error"];
      Helper.showMyToast(text ?? result);
      return null;
    }
  }

  Future<String?> getEventTitleFromPrompt(String prompt) async {
    const String titleGetPrompt =
        "You are a intelligent Ai, You will tell Event title in just one line between double quotes";

    var headers = {
      'Content-Type': 'application/json',
      'X-API-KEY': SharedPrefsUtils.getApiKey()!
    };
    var request =
        http.Request('POST', Uri.parse('https://api.bitapai.io/cortext'));

    request.body = json.encode({
      "messages": [
        {"role": "system", "content": titleGetPrompt},
        {
          "role": "user",
          "content": prompt,
        }
      ],
      // "uids": [387, 158, 40, 410, 187, 500, 846],
      "count": 10,
      "return_all": false
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      String text = jsonDecode(result)["choices"][0]["message"]["content"];
      return extractTitle(text);
    } else {
      var result = await response.stream.bytesToString();
      String? text = jsonDecode(result)["error"];
      Helper.showMyToast(text ?? result);
      return null;
    }
  }

  Future<bool> isAppOpenTask(String prompt) async {
    if (prompt.toLowerCase().contains("send mail") ||
        prompt.toLowerCase().contains("send email") ||
        prompt.toLowerCase().contains("open gmail") ||
        prompt.toLowerCase().contains("send gmail")) {
      await LaunchApp.openApp(
        androidPackageName: 'com.google.android.gm',
      );
      return true;
    } else if (prompt.toLowerCase().contains("open whatsapp") ||
        prompt.toLowerCase().contains("send message on whatsapp") ||
        prompt.toLowerCase().contains("call whatsapp")) {
      await LaunchApp.openApp(
        androidPackageName: 'com.whatsapp',
      );
      return true;
    } else if (prompt.toLowerCase().contains("open youtube") ||
        prompt.toLowerCase().contains("play youtube") ||
        prompt.toLowerCase().contains("watch youtube") ||
        prompt.toLowerCase().contains("play songs on youtube")) {
      await LaunchApp.openApp(
        androidPackageName: 'com.google.android.youtube',
      );
      return true;
    } else if (prompt.toLowerCase().contains("open telegram") ||
        prompt.toLowerCase().contains("send message on telegram") ||
        prompt.toLowerCase().contains("call telegram")) {
      await LaunchApp.openApp(
        androidPackageName: 'org.telegram.messenger',
      );
      return true;
    } else if (prompt.toLowerCase().contains("open telegram") ||
        prompt.toLowerCase().contains("send message on telegram") ||
        prompt.toLowerCase().contains("call telegram")) {
      await LaunchApp.openApp(
        androidPackageName: 'org.telegram.messenger',
      );
      return true;
    } else if (prompt.toLowerCase().contains("open telegram") ||
        prompt.toLowerCase().contains("send message on telegram") ||
        prompt.toLowerCase().contains("call telegram")) {
      await LaunchApp.openApp(
        androidPackageName: 'org.telegram.messenger',
      );
      return true;
    } else {
      return false;
    }
  }

  Future<String?> isTask(String prompt) async {
    if (prompt.toLowerCase().contains("whats time") ||
        prompt.toLowerCase().contains("current time & date") ||
        prompt.toLowerCase().contains("what's time") ||
        prompt.toLowerCase().contains("whats time") ||
        prompt.toLowerCase().contains("whats the time") ||
        prompt.toLowerCase().contains("what's the time") ||
        prompt.toLowerCase().contains("tell me time") ||
        prompt.toLowerCase().contains("tell me the time") ||
        prompt.toLowerCase().contains("current date")) {
      return "Sure, The current time & date is ${Helper.getFormattedTime(DateTime.now().microsecondsSinceEpoch, isSingleLine: true)} . ";
    } else if (prompt.toLowerCase().contains("today weather") ||
        prompt.toLowerCase().contains("whats the weather") ||
        prompt.toLowerCase().contains("what's the weather") ||
        prompt.toLowerCase().contains("whats the forecast") ||
        prompt.toLowerCase().contains("what's the forecast") ||
        prompt.toLowerCase().contains("weather toady") ||
        prompt.toLowerCase().contains("forecast toady") ||
        prompt.toLowerCase().contains("today forecast")) {
      return await fetchWeather();
    }

    //  else if (prompt.toLowerCase().contains("who are you?") ||
    //     prompt.toLowerCase().contains("who are you") ||
    //     prompt.toLowerCase().contains("who are u")) {
    //   return """You're are an AI virtual assistant named LISA, developed by Tenet and powered by Corcel.""";
    // }

    else {
      return null;
    }
  }

  Future<String?> getCityName() async {
    const apiUrl = 'https://ipinfo.io/json';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final city = decodedResponse['city'];
      return city;
    }
    return null;
  }

  Future<String?> fetchWeather() async {
    var cityName = await getCityName();
    if (cityName == null) {
      Helper.showMyToast("Server Error");
      return null;
    }
    print('City Name $cityName');
    const apiKey = 'c92f99243df3474fbe5102458231208';
    final apiUrl =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$cityName&aqi=no';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      var weather = decodedResponse['current']['condition']['text'];
      print('Weather $weather');
      String weatherInfo = """
Weather Update 

- Temperature: ${decodedResponse['current']['temp_c']}°C (${decodedResponse['current']['temp_f']}°F). Feels like ${decodedResponse['current']['feelslike_c']}°C (${decodedResponse['current']['feelslike_f']}°F).
- Condition: ${decodedResponse['current']['condition']['text']}.
- Wind: Wind is ${decodedResponse['current']['wind_kph']} kph (${decodedResponse['current']['wind_mph']} mph).
- Atmospheric Pressure: ${decodedResponse['current']['pressure_mb']} mb (${decodedResponse['current']['pressure_in']} in).
- Humidity: ${decodedResponse['current']['humidity']}% with ${decodedResponse['current']['cloud']}% cloud coverage.
- Visibility: ${decodedResponse['current']['vis_km']} km (${decodedResponse['current']['vis_miles']} miles).
- UV Index: ${decodedResponse['current']['uv']} (Moderate exposure risk).

Stay safe and plan accordingly!

""";

      return weatherInfo;
    } else {
      return null;
    }
    // throw Exception('Failed to fetch weather data');
  }

  String? extractTime(String text) {
    final RegExp regex = RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}');
    final match = regex.firstMatch(text);

    if (match != null) {
      return match.group(0);
    } else {
      return null;
    }
  }

  String? extractTitle(String text) {
    print('In Extract $text');
    final RegExp regex = RegExp(r'"(.*?)"');
    final match = regex.firstMatch(text);

    if (match != null) {
      return match.group(0);
    } else {
      return null;
    }
  }

  showNotif() async {
    const String groupKey = 'com.android.example.WORK_EMAIL';
    const String groupChannelId = 'grouped channel id';
    const String groupChannelName = 'grouped channel name';
    const String groupChannelDescription = 'grouped channel description';
  }

  Future<String> scheduleTask(String prompt) async {
    String? time = await getTimeFromPrompt(prompt);
    DateTime currentTime = DateTime.now();
    print('Time Before $time');
    if (time == null) {
      return "Schedule again with Time & date.";
    }
    if (DateTime.parse(time).isBefore(currentTime)) {
      return "Date & time is from past";
    }
    print('Time After $time');

    String? title = await getEventTitleFromPrompt(prompt);
    print('Titleee $title');

    if (title == null) {
      return "Sorry! Unable to get Title, Please try again";
    }
    await SharedPrefsUtils.addEvent({"key": time, "title": title});
    // await setReminder(time);
    await addEvent(title, time);
    return "Confirm all details and save...\n\n\nTo check all events & reminders try command 'Show all events'\n\n\nTo clear Events & reminder, Try 'clear all events'.";
  }

  String showAllTasks() {
    List<Map<String, dynamic>> events = SharedPrefsUtils.getEvents();
    if (events.isEmpty) {
      return "No Events or Reminders are available";
    }
    String response =
        "There are ${events.length} Events/Reminder are scheduled\n";
    for (int i = 1; i <= events.length; i++) {
      response +=
          "\n\n$i - ${events[i - 1]['title']}\n(${Helper.getFormattedTime(DateTime.parse(events[i - 1]['key']).microsecondsSinceEpoch, isSingleLine: true)})";
    }
    return response;
  }

  deleteAllTasks() async {
    await SharedPrefsUtils.clearEvents();
    return "All Scheduled are cleared";
  }

  clearChat() async {
    await SharedPrefsUtils.clearMessages("lisa");
    return "All Previous Conversation is cleared";
  }

  String? isEvent(String prompt) {
    if (prompt.toLowerCase().contains("schedule task") ||
        prompt.toLowerCase().contains("schedule event") ||
        prompt.toLowerCase().contains("remind me") ||
        prompt.toLowerCase().contains("set reminder") ||
        prompt.toLowerCase().contains("add reminder") ||
        prompt.toLowerCase().contains("set event") ||
        prompt.toLowerCase().contains("set alarm")) {
      return "schedule_task";
    } else if (prompt.toLowerCase().contains("tell me events") ||
        prompt.toLowerCase().contains("show all reminders") ||
        prompt.toLowerCase().contains("show all reminder") ||
        prompt.toLowerCase().contains("show all events") ||
        prompt.toLowerCase().contains("show all event") ||
        prompt.toLowerCase().contains("show events") ||
        prompt.toLowerCase().contains("tell events") ||
        prompt.toLowerCase().contains("any event") ||
        prompt.toLowerCase().contains("any reminder") ||
        prompt.toLowerCase().contains("get alarm") ||
        prompt.toLowerCase().contains("show alarm")) {
      return "show_all_tasks";
    } else if (prompt.toLowerCase().contains("clear conversation") ||
        prompt.toLowerCase().contains("clear conversations") ||
        prompt.toLowerCase().contains("clear our conversation") ||
        prompt.toLowerCase().contains("clear all conversation") ||
        prompt.toLowerCase().contains("clear all conversations") ||
        prompt.toLowerCase().contains("clear all chats") ||
        prompt.toLowerCase().contains("clear all chat") ||
        prompt.toLowerCase().contains("clear chat") ||
        prompt.toLowerCase().contains("clear chats") ||
        prompt.toLowerCase().contains("clear our conversations")) {
      return "clear_chat";
    } else if (prompt.toLowerCase().contains("clear all events") ||
        prompt.toLowerCase().contains("clear all reminders") ||
        prompt.toLowerCase().contains("clear all alarms")) {
      return "delete_all_tasks";
    } else {
      return null;
    }
  }

// Orb

  final RxString _getOrb = "1".obs;

  RxString get getOrb => _getOrb;

  setOrb(String orb) {
    _getOrb.value = orb;
    update();
  }

  // function to get or update chat List
  List<ChatModel> _chatList = [];

  List<ChatModel> get chatList => _chatList;

  setChatList(List<ChatModel> chatData) {
    _chatList = chatData;

    update();
  }

  updateChat(ChatModel chat) {
    _chatList.add(chat);
    update();
  }

  deleteChat() {
    chatList.clear();
    update();
  }

  // Update ai response

  String _getAIResponse = "";
  String get getAiResponse => _getAIResponse;
  updateResponse(String data) {
    _getAIResponse += data;
    update();
  }

  clearAiResponse() {
    _getAIResponse = "";
    update();
  }
}
