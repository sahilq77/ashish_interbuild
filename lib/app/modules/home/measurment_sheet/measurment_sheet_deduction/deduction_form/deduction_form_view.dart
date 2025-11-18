import 'package:ashishinterbuild/app/common/custominputformatters/number_input_formatter.dart';
import 'package:ashishinterbuild/app/common/custominputformatters/securetext_input_formatter.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_deduction/deduction_form/deduction_form_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeductionFormView extends StatefulWidget {
  const DeductionFormView({super.key});

  @override
  State<DeductionFormView> createState() => _DeductionFormViewState();
}

class _DeductionFormViewState extends State<DeductionFormView> {
  // Add this GlobalKey
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final DeductionFormController controller = Get.put(
      DeductionFormController(),
    );
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.padding(16),
          child: Form(
            // Wrap with Form widget
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: Column(
              children: [
                _buildTextFormField(
                  label: 'Nos.*',
                  controller: controller.nosController,
                  hint: 'Enter Nos.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Nos.';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                _buildTextFormField(
                  label: 'Length (m) *',
                  controller: controller.lengthController,
                  hint: 'Enter Length',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Length';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid positive length';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                _buildTextFormField(
                  label: 'Breadth (m) *',
                  controller: controller.breadthController,
                  hint: 'Enter Breadth',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Breadth';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid positive breadth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                _buildTextFormField(
                  label: 'Height (m) *',
                  controller: controller.heightController,
                  hint: 'Enter Height',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Height';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Enter a valid positive height';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                _buildTextFormField(
                  label: 'Calculated Quantity',
                  controller: controller.calculatedQtyController,
                  hint: 'Auto-calculated',
                  readOnly: true,
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.05),
                ElevatedButton(
                  onPressed: () {
                    // Validate form before submitting
                    if (_formKey.currentState!.validate()) {
                      controller.submitForm();
                      Navigator.pop(context);
                    }
                  },
                  style: AppButtonStyles.elevatedLargeBlack(),
                  child: Text(
                    "Submit",
                    style: AppStyle.buttonTextPoppinsWhite.responsive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: validator, // Add validator here
          inputFormatters: [
            SecureTextInputFormatter.deny(),
            NumberInputFormatter(),
          ],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            errorStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[200] : null,
          ),
        ),
      ],
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Add Deduction',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
