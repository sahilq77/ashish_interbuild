import 'package:ashishinterbuild/app/utils/app_images.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
// REMOVED: No need for splash_controller import if using GetBuilder below

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // REMOVED: initState() - navigation now in controller

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    // NEW: Use GetBuilder to init controller (ensures onInit runs on view load)
    return GetBuilder<SplashController>(
      init: SplashController(), // Triggers onInit() with initialize()
      builder: (controller) => Scaffold(
        body: Center(
          child: Image.asset(
            AppImages.splash,
            fit: BoxFit.cover,
            height: ResponsiveHelper.screenHeight * 0.13,
          ),
        ),
      ),
    );
  }
}
