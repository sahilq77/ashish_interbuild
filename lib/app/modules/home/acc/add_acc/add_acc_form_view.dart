import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAccIssueFormView extends StatefulWidget {
  const AddAccIssueFormView({super.key});

  @override
  State<AddAccIssueFormView> createState() => _AddAccIssueFormViewState();
}

class _AddAccIssueFormViewState extends State<AddAccIssueFormView> {
  final projectdController = Get.find<ProjectNameDropdownController>();
  final packageNameController = Get.find<PackageNameController>();
  final accCategoryController = Get.find<AccCategoryController>();
  final doerRoleController = Get.find<DoerRoleController>();

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
              Obx(
                () => _buildDropdownField(
                  label: 'Project *',
                  value: controller.selectedProject.value,
                  items: projectdController.projectNames,
                  onChanged: controller.onProjectChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an Project'
                      : null,
                  hint: 'Select Project',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'Package *',
                  value: controller.selectedPackage.value,
                  items: packageNameController.packageNames,
                  onChanged: controller.onPackageChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an Package'
                      : null,
                  hint: 'Select Package',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Obx(
                () => _buildDropdownField(
                  label: 'ACC Category *',
                  value: controller.accCategory.value,
                  items: accCategoryController.accCategoryNames,
                  onChanged: controller.onAccCategoryChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select an ACC category'
                      : null,
                  hint: 'Select Category',
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Priority',
                value: controller.priority.value,
                items: controller.priorities,
                onChanged: controller.onPriorityChanged,
                hint: 'Select Priority',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Key Delay Events',
                value: controller.keyDelayEvents.value,
                items: controller.keyDelayOptions,
                onChanged: controller.onKeyDelayEventsChanged,
                hint: 'Yes',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDropdownField(
                label: 'Affected Milestone *',
                value: controller.affectedMilestone.value,
                items: controller.milestones,
                onChanged: controller.onAffectedMilestoneChanged,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select an affected milestone'
                    : null,
                hint: 'Select Milestone',
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildTextFormField(
                label: 'Brief Details *',
                initialValue: controller.briefDetails.value,
                onChanged: controller.onBriefDetailsChanged,
                hint: 'Detail',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter brief details'
                    : null,
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              _buildDateField(
                label: 'Issue Open Date *',
                selectedDate: controller.issueOpenDate.value,
                onDateChanged: controller.onIssueOpenDateChanged,
                hint: 'Enter Date',
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
              _buildAttachmentField(
                label: 'Attachment',
                fileName: controller.attachmentFileName.value,
                onAttachmentPicked: controller.pickAttachment,
                hint: 'Choose File',
              ),
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
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
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
        'Add ACC Issue Form',
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
