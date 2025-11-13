import 'package:ashishinterbuild/app/utils/app_images.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart'
    show AppButtonStyles;
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../common/custominputformatters/securetext_input_formatter.dart';
import '../../common/customvalidators/text_validator.dart';
import '../../utils/app_colors.dart';
import '../../utils/responsive_utils.dart';
import 'login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Form(
            key: controller.formKey,
            autovalidateMode:
                AutovalidateMode.onUserInteraction, // <-- real-time validation
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: ResponsiveHelper.paddingSymmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: ResponsiveHelper.spacing(60)),
                  Image.asset(
                    AppImages.splash,
                    fit: BoxFit.cover,
                    height: ResponsiveHelper.screenHeight * 0.13,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(40)),
                  ResponsiveHelper.safeText(
                    'User Login',
                    style: AppStyle.heading2PoppinsBlack.responsive,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(48)),

                  // ---------- USERNAME ----------
                  _buildLabel('Enter your username'),
                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  TextFormField(
                    key: controller.emailFieldKey,
                    controller: controller.emailController,
                    focusNode: controller.emailFocusNode,
                    keyboardType: TextInputType.text,
                    validator: TextValidator.isUsername,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      LengthLimitingTextInputFormatter(50),
                    ],
                    decoration: _inputDecoration(
                      hint: 'Enter username',
                      prefixIcon: Icons.person,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(24)),

                  // ---------- PASSWORD ----------
                  _buildLabel('Enter your password'),
                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocusNode,
                      obscureText: controller.isPasswordHidden.value,
                      validator: TextValidator.isPassword,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        SecureTextInputFormatter(),
                      ],
                      decoration: _inputDecoration(
                        hint: 'Enter password',
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
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(48)),

                  // ---------- LOGIN BUTTON ----------
                  SizedBox(
                    height: ResponsiveHelper.spacing(50),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          controller.formKey.currentState?.validate() ?? false
                          ? () {
                              // hide keyboard
                              FocusScope.of(context).unfocus();

                              // call login with real data
                              controller.login(
                                mobile: controller.emailController.text.trim(),
                                password: controller.passwordController.text,
                                deviceToken: "",
                              );
                            }
                          : null, // disabled when invalid
                      style: AppButtonStyles.elevatedLargeBlack(),
                      child: ResponsiveHelper.safeText(
                        'Login',
                        style: AppStyle.buttonTextPoppinsWhite.responsive,
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(40)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // Helper widgets
  // -----------------------------------------------------------------
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
