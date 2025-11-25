// forgot_password_controller.dart
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  // Form keys
  final verifyEmailFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus nodes
  final emailFocusNode = FocusNode();
  final newPasswordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  // Observables
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var currentStep = 1.obs; // 1 = Verify Email, 2 = Reset Password

  @override
  void onClose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    emailFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  // Toggle visibility
  void togglePasswordVisibility() => isPasswordHidden.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.toggle();

  // Step 1: Verify Email
  void verifyEmail() {
    if (verifyEmailFormKey.currentState!.validate()) {
      // TODO: Call your API to send OTP or verification link

      AppSnackbarStyles.showSuccess(
        title: "Success",
        message: "Verification code sent to your email",
      );
      currentStep.value = 2; // Move to reset password step
    }
  }

  // Step 2: Reset Password
  void resetPassword() {
    if (resetPasswordFormKey.currentState!.validate()) {
      if (newPasswordController.text != confirmPasswordController.text) {
        AppSnackbarStyles.showError(
          title: "Error",
          message: "Passwords do not match",
        );

        return;
      }

      // TODO: Call API to update password

      AppSnackbarStyles.showSuccess(
        title: "Success",
        message: "Password changed successfully",
      );
      // Go back to login
      Get.back(); // or Get.offAll(() => LoginView());
    }
  }

  void goBackToEmailStep() {
    currentStep.value = 1;
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
}
