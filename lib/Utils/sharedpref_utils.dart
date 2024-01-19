import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color_resources.dart';

const String keysList = "keys_list";
const String introText = "You are an AI assistant, Whose name is 'LISA'.";

class SharedPrefsUtils {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static final Rx<Color> _themeColor = Rx<Color>(ColorResources.primaryColor);

  static Color getThemeColor() {
    if (_prefs.getInt("theme_color") != null) {
      return Color(_prefs.getInt("theme_color")!);
    } else {
      return _themeColor.value;
    }
  }

  static Future setThemeColor(Color color) async {
    _themeColor.value = color;
    return await _prefs.setInt("theme_color", color.value);
  }

  static saveUserKey(String secretKey) async {
    await _prefs.setString("secret_key", secretKey);
  }

  static String? getUserKey() {
    return _prefs.getString("secret_key");
  }

  static String getOrb() {
    return _prefs.getString("orb") ?? "1";
  }

  static Future<bool> setOrb(String orb) async {
    return await _prefs.setString("orb", orb);
  }

  static String getVoice() {
    return _prefs.getString("voice") ?? "en-us-x-tpf-local";
  }

  static setCurrentChatId(String id) {
    return _prefs.setString("currentChat", id);
  }

  static String getCurrentChatId() {
    return _prefs.getString("currentChat") ?? "0";
  }

  static Future<bool> setVoice(String orb) async {
    return await _prefs.setString("voice", orb);
  }

  static removeUserKey() async {
    await _prefs.remove("secret_key");
  }

  static bool isFirst() {
    return _prefs.getBool("is_first") ?? true;
  }

  static Future<bool> setFirstFalse() async {
    return await _prefs.setBool("is_first", false);
  }

  static List<Map<String, dynamic>> getMessages(String key) {
    // print("Key Checker :::: $key");
    String jsonString = _prefs.getString(key) ?? '[]';

    // print("Json Sting Data ::: $jsonString");
    List<dynamic> decodedList = jsonDecode(jsonString);
    List<Map<String, dynamic>> list = decodedList
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
        .toList();
    if (list.isEmpty) {
      list.add({"role": "system", "content": introText});
    }

    return list;
  }

  static Future<List<Map<String, dynamic>>> addItem(
      String key, Map<String, dynamic> item) async {
    List<Map<String, dynamic>> currentList = getMessages(key);
    currentList.add(item);
    await setMessages(key, currentList);
    return currentList;
  }

  static Future<void> setMessages(
      String key, List<Map<String, dynamic>> list) async {
    String jsonString = jsonEncode(list);
    await _prefs.setString(key, jsonString);
  }

  static Future<void> clearMessages(String key) async {
    await _prefs.remove(key);
  }

  static Future<List<String>> addKey(String key) async {
    List<String> currentList = getKeys();
    currentList.add(key);
    await _prefs.setStringList(keysList, currentList);
    return currentList;
  }

  static Future<List<String>> removeOneKey(String key) async {
    List<String> currentList = getKeys();
    currentList.removeWhere((element) => element == key);
    await _prefs.setStringList(keysList, currentList);
    return currentList;
  }

  static Future<List<String>> removeSingleHistory(String key) async {
    List<String> currentList = getHistory();
    currentList.removeWhere((element) => element == key);
    await _prefs.setStringList("history", currentList);
    return currentList;
  }

  static List<String> getKeys() {
    return _prefs.getStringList(keysList) ?? [];
  }

  static setHistory(history) {
    return _prefs.setStringList("history", history) ?? [];
  }

  static List<String> getHistory() {
    return _prefs.getStringList("history") ?? [];
  }

  static clearMessageHistory() {
    return _prefs.setStringList("history", []) ?? [];
  }

  static String? getApiKey() {
    return _prefs.getString("api_key");
  }

  static setApiKey(String apiKey) async {
    await _prefs.setString("api_key", apiKey);
    // await _prefs.setString("api_key", "6978da73-d9ab-40f9-aa8a-7699ad52db73");
  }

/////////////////////////////////
  static List<Map<String, dynamic>> getEvents() {
    String jsonString = _prefs.getString("events") ?? '[]';
    List<dynamic> decodedList = jsonDecode(jsonString);
    List<Map<String, dynamic>> list = decodedList
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
        .toList();

    return list;
  }

  static String? getOneEvent(String key) {
    List<Map<String, dynamic>> currentList = getEvents();
    String? title;
    for (var element in currentList) {
      if (element['key'] == key) {
        title = element['key'];
        break;
      }
    }
    return title;
  }

  static Future<List<Map<String, dynamic>>> addEvent(
      Map<String, dynamic> item) async {
    List<Map<String, dynamic>> currentList = getEvents();
    currentList.add(item);
    _prefs.setString("events", jsonEncode(currentList));
    return currentList;
  }

  static Future<void> clearEvents() async {
    await _prefs.remove("events");
  }
}
