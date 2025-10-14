// lib/app/modules/splash/splash_controller.dart
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // NEW: Call initialize() to load flags from prefs
    AppUtility.initialize().then((_) {
      // Delay for splash animation, then navigate based on flags
      Future.delayed(const Duration(seconds: 3), () {
        // Point 1: If onboarding seen, skip it
        if (AppUtility.isLoggedIn) {
          Get.offNamed(AppRoutes.home);
        } else {
          Get.offNamed(AppRoutes.login);
        }
      });
    });
  }
}
