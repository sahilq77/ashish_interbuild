import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordHidden = true.obs;
  final formKey = GlobalKey<FormState>();
  late FocusNode usernameFocusNode;
  late FocusNode passwordFocusNode;
  final GlobalKey usernameFieldKey = GlobalKey();
  final GlobalKey passwordFieldKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    usernameFocusNode.addListener(_onUsernameFocusChange);
    passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onUsernameFocusChange() {
    if (usernameFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = usernameFieldKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _onPasswordFocusChange() {
    if (passwordFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = passwordFieldKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    AppUtility.setUserInfo(
      "Sahil",
      "77798557656",
      '',
      'dummy_user_',
      'dummy_plant_1',
      1,
    ).then((val) {
      // Navigate with arguments
      Get.offNamed(AppRoutes.home);
    });
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
