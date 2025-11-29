import 'dart:convert';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/login/get_login_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/service/notfication_services.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart'; // <-- Added
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
  RxBool isLoading = false.obs;
  RxString deviceToken = ''.obs;
 NotificationServices notificationServices = NotificationServices();
  @override
  void onInit() {
    super.onInit();
    notificationServices.firebaseInit(Get.context!);
    notificationServices.setInteractMessage(Get.context!);
    notificationServices.getDevicetoken().then((value) {
      deviceToken.value=value;
      log('Device Token ${value}');
      // pushtoken = value;
    });
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

  // -----------------------------------------------------------------
  // LOGIN METHOD
  // -----------------------------------------------------------------
  // -----------------------------------------------------------------
  // LOGIN METHOD
  // -----------------------------------------------------------------
  Future<void> login({
    BuildContext? context,
    required String? mobile,
    required String? password,
    // required String? deviceToken,
  }) async {
    log(AppUtility.authToken.toString());

    try {
      final jsonBody = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "fcm_token":deviceToken.value
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.login,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        // Properly parse the list using your helper function
        List<GetLoginResponse> response = getLoginResponseFromJson(
          jsonEncode(list),
        );

        if (response[0].status == true) {
          log(response[0].data!.userRoleId);
          final user = response[0].data;

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

          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: 'Sign in successfully!',
          );

          Get.offNamed(AppRoutes.home);
        } else if (response[0].status == false) {
          // Use actual error or message from API
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Invalid credentials. Please try again.");

          AppSnackbarStyles.showError(
            title: 'Login Failed',
            message: errorMessage,
          );
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Login Failed',
          message: "Invalid credentials. Please try again.",
        );
        // AppSnackbarStyles.showError(
        //   title: 'Server Error',
        //   message: 'No response from server',
        // );
      }
    } on NoInternetException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'Unexpected Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   emailFocusNode.dispose();
  //   passwordFocusNode.dispose();
  //   super.onClose();
  // }
}
