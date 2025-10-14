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
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                // Username field
                Align(
                  alignment: Alignment.centerLeft,
                  child: ResponsiveHelper.safeText(
                    'Enter your username',
                    style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                TextFormField(
                  key: controller.usernameFieldKey,
                  controller: controller.usernameController,
                  focusNode: controller.usernameFocusNode,
                  keyboardType: TextInputType.text,
                  validator: (value) => TextValidator.isUsername(value),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: ResponsiveHelper.getResponsiveFontSize(20),
                    ),
                    hintText: 'Enter username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.spacing(12),
                      ),
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.spacing(12),
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: ResponsiveHelper.paddingSymmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(24)),
                // Password field
                Align(
                  alignment: Alignment.centerLeft,
                  child: ResponsiveHelper.safeText(
                    'Enter your password',
                    style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    focusNode: controller.passwordFocusNode,
                    obscureText: controller.isPasswordHidden.value,
                    validator: (value) => TextValidator.isPassword(value),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                      SecureTextInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: AppColors.primary,
                        size: ResponsiveHelper.getResponsiveFontSize(20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.grey,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      hintText: 'Enter password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.spacing(12),
                        ),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.spacing(12),
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: ResponsiveHelper.paddingSymmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(48)),
                // Login button
                SizedBox(
                  height: ResponsiveHelper.spacing(50),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.login,
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
    );
  }
}
