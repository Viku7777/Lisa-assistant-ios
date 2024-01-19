import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lisa_ai/main/main_binding.dart';
import 'package:lisa_ai/main/screens/Chat/chat_dashboard.dart';
import 'package:lisa_ai/main/screens/Chat/chat_history.dart';
import 'package:lisa_ai/main/screens/Chat/chat_screen.dart';
import 'package:lisa_ai/main/screens/Chat/create_chat.dart';
import 'package:lisa_ai/main/screens/Motion/motion_view.dart';
import 'package:lisa_ai/main/screens/dashboard_screen.dart';
import 'package:lisa_ai/main/screens/note_screen.dart';
import 'package:lisa_ai/main/screens/setting_screen.dart';
import 'package:lisa_ai/main/screens/vision_screen.dart';
import 'package:lisa_ai/main/screens/voice/voice_view.dart';
import 'Utils/color_resources.dart';
import 'Utils/sharedpref_utils.dart';
import 'Utils/strings.dart';
import 'Utils/theme_controller.dart';
import 'firebase_options.dart';
import 'main/screens/menu_screen.dart';
import 'main/screens/setting2_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsUtils.init();
  Get.put(SharedPrefsUtils());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MyApp());
  // runApp(const TestScreenView());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Color _color = SharedPrefsUtils.getThemeColor();

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatches = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatches[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatches);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeCtrl) {
        final customThemeData = ThemeData(
          fontFamily: 'SpaceMono',
          primaryColor: themeCtrl.getThemeColor(),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(themeCtrl.getThemeColor()),
          ).copyWith(
            secondary: ColorResources.secondaryColor,
          ),
        );
        return GetMaterialApp(
          title: Strings.appName,
          debugShowCheckedModeBanner: false,
          theme: customThemeData,
          onInit: () {
            Get.put(MainBinding());
          },
          initialBinding: MainBinding(),
          initialRoute: DashboardScreen.routeName,
          getPages: [
            GetPage(
              name: DashboardScreen.routeName,
              page: () => const DashboardScreen(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: SettingScreen.routeName,
              page: () => SettingScreen(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: Setting2Screen.routeName,
              page: () => Setting2Screen(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: MenuScreen.routeName,
              page: () => MenuScreen(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: ChatDashboard.routeName,
              page: () => ChatDashboard(msg: const []),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: CreateChatView.routeName,
              page: () => const CreateChatView(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: CreateMotionView.routeName,
              page: () => const CreateMotionView(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: ChatHistoryView.routeName,
              page: () => const ChatHistoryView(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: CreateVoiceView.routeName,
              page: () => const CreateVoiceView(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            GetPage(
              name: ChatScreen.routeName,
              page: () => const ChatScreen(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
            // GetPage(
            //   name: NoteScreenView.routeName,
            //   page: () => const NoteScreenView(),
            //   binding: MainBinding(),
            //   preventDuplicates: true,
            // ),
            GetPage(
              name: VisionScreenView.routeName,
              page: () => const VisionScreenView(),
              binding: MainBinding(),
              preventDuplicates: true,
            ),
          ],
        );
      },
    );
  }
}
