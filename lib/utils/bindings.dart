// bindings.dart
import 'package:automail/controllers/email_composer_controller.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}

class EmailComposerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailComposerController());
  }
}
