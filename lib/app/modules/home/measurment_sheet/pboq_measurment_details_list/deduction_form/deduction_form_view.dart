import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/deduction_form/deduction_form_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeductionFormView extends StatelessWidget {
  const DeductionFormView({super.key});

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
          child: Column(
            children: [
              _buildTextFormField(
                label: 'Nos.',
                controller: controller.nosController,
                hint: 'Enter Nos.',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Length (m)',
                controller: controller.lengthController,
                hint: 'Enter Length',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Breadth (m)',
                controller: controller.breadthController,
                hint: 'Enter Breadth',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Height (m)',
                controller: controller.heightController,
                hint: 'Enter Height',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.05),
              ElevatedButton(
                onPressed: controller.submitForm,
                style: AppButtonStyles.elevatedLargePrimary(),
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.white),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Deduction',
        style: AppStyle.heading1PoppinsWhite.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
