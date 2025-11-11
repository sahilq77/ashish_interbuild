import 'dart:convert';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/login/get_login_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/networkutility.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordHidden = true.obs;
  final formKey = GlobalKey<FormState>();
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  final GlobalKey emailFieldKey = GlobalKey();
  final GlobalKey passwordFieldKey = GlobalKey();
  RxBool isLoading = false.obs; // Changed initial value to false

  @override
  void onInit() {
    super.onInit();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    emailFocusNode.addListener(_onUsernameFocusChange);
    passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onUsernameFocusChange() {
    if (emailFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = emailFieldKey.currentContext;
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

  Future<void> login({
    BuildContext? context,
    required String? mobile,
    required String? password,
    required String? deviceToken,
  }) async {
    log(AppUtility.authToken.toString());
    try {
      // Use controller values directly since they are validated by the form
      final jsonBody = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        // "device_token": deviceToken.toString(),
      };

      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.login,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);

        if (response[0].status == true) {
          log(response[0].data!.userRoleId);
          final user = response[0].data;

          // Save credentials if "Remember Me" is checked

          await AppUtility.setUserInfo(
            user!.loginType,
            emailController.text.trim(),
            user.profilePicPath,
            user.userId,
            '',
            user.userRoleId,
            user.isAdminUser,
            List<String>.from(user.allowedModules),
            user.authToken,
          );
          Get.snackbar(
            'Success',
            'Sign in successfully!',
            backgroundColor: AppColors.greenColor,
            colorText: Colors.white,
          );
          Get.offNamed(AppRoutes.home);
        } else {
          Get.snackbar(
            'Failed',
            "Your username or password is incorrect.\nPlease try again.",
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.redColor,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
