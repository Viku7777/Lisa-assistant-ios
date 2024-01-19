import 'package:get/get.dart';
import 'main_conntroller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
  }
}
