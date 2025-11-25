// forgot_password_view.dart
import 'package:ashishinterbuild/app/utils/app_images.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../common/custominputformatters/securetext_input_formatter.dart';
import '../../common/customvalidators/text_validator.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_utils.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,

        title: ResponsiveHelper.safeText(
          'Forgot Password',
          style: AppStyle.heading2PoppinsBlack.responsive,
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.currentStep.value == 1 ? 0 : 1,
            children: [
              // Step 1: Enter Email
              _buildVerifyEmailStep(),
              // Step 2: Reset Password
              _buildResetPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyEmailStep() {
    return Center(
      child: Form(
        key: controller.verifyEmailFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.paddingSymmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: ResponsiveHelper.spacing(40)),
              Image.asset(
                AppImages.splash,
                height: ResponsiveHelper.screenHeight * 0.13,
                fit: BoxFit.cover,
              ),
              SizedBox(height: ResponsiveHelper.spacing(30)),
              ResponsiveHelper.safeText(
                'Don\'t worry! It happens.',
                style: AppStyle.heading2PoppinsBlack.responsive.copyWith(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              ResponsiveHelper.safeText(
                'Enter your registered email address to receive password reset instructions.',
                style: AppStyle.bodyRegularPoppinsGrey.responsive.copyWith(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(48)),

              _buildLabel('Enter your email'),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              TextFormField(
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                validator: TextValidator.isEmail,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  LengthLimitingTextInputFormatter(50),
                ],
                decoration: _inputDecoration(
                  hint: 'Enter email address',
                  prefixIcon: Icons.email,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(40)),

              SizedBox(
                height: ResponsiveHelper.spacing(50),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.verifyEmail,
                  style: AppButtonStyles.elevatedLargeBlack(),
                  child: ResponsiveHelper.safeText(
                    'Send Reset Link',
                    style: AppStyle.buttonTextPoppinsWhite.responsive,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordStep() {
    return Center(
      child: Form(
        key: controller.resetPasswordFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.paddingSymmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: ResponsiveHelper.spacing(40)),
              Image.asset(
                AppImages.splash,
                height: ResponsiveHelper.screenHeight * 0.13,
                fit: BoxFit.cover,
              ),
              SizedBox(height: ResponsiveHelper.spacing(30)),
              ResponsiveHelper.safeText(
                'Create New Password',
                style: AppStyle.heading2PoppinsBlack.responsive.copyWith(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              ResponsiveHelper.safeText(
                'Your new password must be different from previous passwords.',
                style: AppStyle.bodyRegularPoppinsGrey.responsive.copyWith(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.spacing(40)),

              // New Password
              _buildLabel('New Password'),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              TextFormField(
                controller: controller.newPasswordController,
                focusNode: controller.newPasswordFocusNode,
                obscureText: controller.isPasswordHidden.value,
                validator: TextValidator.isPassword,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  SecureTextInputFormatter(),
                ],
                decoration: _inputDecoration(
                  hint: 'Enter new password',
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(24)),

              // Confirm Password
              _buildLabel('Confirm New Password'),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              TextFormField(
                controller: controller.confirmPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                obscureText: controller.isConfirmPasswordHidden.value,
                validator: (value) {
                  if (value != controller.newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return TextValidator.isPassword(value);
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  SecureTextInputFormatter(),
                ],
                decoration: _inputDecoration(
                  hint: 'Re-enter new password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(40)),

              SizedBox(
                height: ResponsiveHelper.spacing(50),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.resetPassword,
                  style: AppButtonStyles.elevatedLargeBlack(),
                  child: ResponsiveHelper.safeText(
                    'Reset Password',
                    style: AppStyle.buttonTextPoppinsWhite.responsive,
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(20)),
              TextButton(
                onPressed: controller.goBackToEmailStep,
                child: ResponsiveHelper.safeText(
                  '← Back to email entry',
                  style: AppStyle.bodyRegularPoppinsPrimary.responsive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: ResponsiveHelper.safeText(
      text,
      style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(fontSize: 15),
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    prefixIcon: Icon(
      prefixIcon,
      color: AppColors.primary,
      size: ResponsiveHelper.getResponsiveFontSize(20),
    ),
    suffixIcon: suffixIcon,
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      borderSide: const BorderSide(color: AppColors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(12)),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    contentPadding: ResponsiveHelper.paddingSymmetric(
      horizontal: 16,
      vertical: 16,
    ),
  );
}
