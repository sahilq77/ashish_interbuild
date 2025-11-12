import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditClientCommitmentFormView extends StatelessWidget {
  const EditClientCommitmentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final AddAccIssueFormController controller = Get.put(
      AddAccIssueFormController(),
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
              _buildDropdownField(
                label: 'Task Assigned To (Name)*',
                value: controller.role.value,
                items: controller.roles,
                onChanged: controller.onRoleChanged,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a task assignee'
                    : null,
                hint: 'Select Task Assigned To (Name)',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'HOD*',
                initialValue: '', // Add HOD to controller if needed
                onChanged: (value) {
                  // Add HOD logic to controller if required
                },
                hint: 'HOD',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter HOD' : null,
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'CC (Name)*',
                value: controller.accCategory.value,
                items: controller.accCategories,
                onChanged: controller.onAccCategoryChanged,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a CC'
                    : null,
                hint: 'Select CC',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Task Details*',
                initialValue: controller.briefDetails.value,
                onChanged: controller.onBriefDetailsChanged,
                hint: 'Enter Task Details',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter task details'
                    : null,
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDateField(
                label: 'Initial Target Date*',
                selectedDate: controller.issueOpenDate.value,
                onDateChanged: controller.onIssueOpenDateChanged,
                hint: 'Select Date',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Category*',
                value: controller.category.value,
                items: controller.categories,
                onChanged: controller.onPriorityChanged,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a category'
                    : null,
                hint: 'Select Category',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Affected Milestone',
                value: controller.affectedMilestone.value,
                items: controller.milestones,
                onChanged: controller.onAffectedMilestoneChanged,
                hint: 'Select Affected Milestone',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDateField(
                label: 'Milestone Target Date',
                selectedDate: DateTime.now(), // Add to controller if needed
                onDateChanged: (date) {
                  // Add milestone target date logic to controller
                },
                hint: 'Select Date',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Priority*',
                value: controller.priority.value,
                items: controller.priorities,
                onChanged: controller.onPriorityChanged,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a Priority'
                    : null,
                hint: 'Select Priority',
              ),
              // _buildAttachmentField(
              //   label: 'Final Attachment* (Required : PNG,JPG,JPEG)',
              //   fileName: controller.attachmentFileName.value,
              //   onAttachmentPicked: controller.pickAttachment,
              //   hint: 'Choose File',
              //   validator: (value) => value == 'No file chosen'
              //       ? 'Please select a file (PNG, JPG, JPEG)'
              //       : null,
              // ),
              // SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              // _buildTextFormField(
              //   label: 'Remarks',
              //   initialValue: '',
              //   onChanged: (value) {
              //     // Add remarks logic to controller if needed
              //   },
              //   hint: 'Enter Remarks',
              // ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.05),
              ElevatedButton(
                onPressed: controller.submitForm,
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  'Submit',
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
    String? Function(String?)? validator,
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
          validator: validator,
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
    String? Function(String?)? validator,
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
              validator: validator,
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
        'Edit Client Commitment',
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
