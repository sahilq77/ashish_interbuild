import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_acc_form_controller.dart';

class UpdateAccFormView extends StatefulWidget {
  const UpdateAccFormView({super.key});

  @override
  State<UpdateAccFormView> createState() => _UpdateAccFormViewState();
}

class _UpdateAccFormViewState extends State<UpdateAccFormView> {
  final doerRoleController = Get.find<DoerRoleController>();
  @override
  Widget build(BuildContext context) {
    final UpdateAccFormController controller = Get.put(
      UpdateAccFormController(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Priority *',
                value: controller.priority.value,
                items: controller.priorities,
                onChanged: controller.onPriorityChanged,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a priority'
                    : null,
                hint: 'Select Priority',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Role *',
                  value: controller.role.value,
                  items: doerRoleController.doerRoleNames,
                  onChanged: controller.onRoleChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a role'
                      : null,
                  hint: 'Select Doer',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDateField(
                label: 'Issue Open Since Date *',
                selectedDate: controller.issueOpenSinceDate.value,
                onDateChanged: controller.onIssueOpenSinceDateChanged,
                hint: 'Enter Date',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDateField(
                label: 'Issue Close Date *',
                selectedDate: controller.issueCloseDate.value,
                onDateChanged: controller.onIssueCloseDateChanged,
                hint: 'Enter Date',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildAttachmentField(
                label: 'Attachment',
                fileName: controller.attachmentFileName.value,
                onAttachmentPicked: controller.pickAttachment,
                hint: 'Choose File',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Remark',
                initialValue: controller.remark.value,
                onChanged: controller.onRemarkChanged,
                hint: 'Enter Remark',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.05),
              ElevatedButton(
                onPressed: controller.submitForm,
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  'Update',
                  style: AppStyle.buttonTextPoppinsWhite.responsive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          selectedItem: value.isNotEmpty ? value : null,
          items: items,
          onChanged: onChanged,
          validator: validator,
          enabled: onChanged != null,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: const PopupProps.menu(showSearchBox: true),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required Function(String)? onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
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

  Widget _buildDateField({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime)? onDateChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: Get.context!,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null && pickedDate != selectedDate) {
              onDateChanged?.call(pickedDate);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: selectedDate.toLocal().toString().split(' ')[0],
              ),
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentField({
    required String label,
    required String fileName,
    required Function() onAttachmentPicked,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAttachmentPicked,
          child: AbsorbPointer(
            child: TextFormField(
              initialValue: fileName,
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: const Icon(Icons.attach_file),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
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
        'Update ACC',
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
