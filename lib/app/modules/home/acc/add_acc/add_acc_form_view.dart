import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_binding.dart';
import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_controller.dart';
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
  final milestoneController = Get.find<MilestoneController>();

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
              // Dynamic Field Sets
              Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.fieldSets.length,
                  itemBuilder: (ctx, index) {
                    final fs = controller.fieldSets[index];
                    return Column(
                      children: [
                        Obx(
                          () => _buildDropdownField(
                            label: 'Project *',
                            value: fs.selectedProject.value,
                            items: projectdController.projectNames,
                            onChanged: (v) =>
                                controller.onProjectChanged(index, v),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select a Project'
                                : null,
                            hint: 'Select Project',
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        Obx(
                          () => _buildDropdownField(
                            label: 'Package *',
                            value: fs.selectedPackage.value,
                            items: packageNameController.packageNames,
                            onChanged: (v) =>
                                controller.onPackageChanged(index, v),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select a Package'
                                : null,
                            hint: 'Select Package',
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        Obx(
                          () => _buildDropdownField(
                            label: 'ACC Category *',
                            value: fs.accCategory.value,
                            items: accCategoryController.accCategoryNames,
                            onChanged: (v) =>
                                controller.onAccCategoryChanged(index, v),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select an ACC category'
                                : null,
                            hint: 'Select Category',
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        _buildDropdownField(
                          label: 'Priority',
                          value: fs.priority.value,
                          items: controller.priorities,
                          onChanged: (v) =>
                              controller.onPriorityChanged(index, v),
                          hint: 'Select Priority',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        _buildDropdownField(
                          label: 'Key Delay Events',
                          value: fs.keyDelayEvents.value,
                          items: controller.keyDelayOptions,
                          onChanged: (v) =>
                              controller.onKeyDelayEventsChanged(index, v),
                          hint: 'Yes',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        Obx(
                          () => _buildDropdownField(
                            label: 'Affected Milestone *',
                            value: fs.affectedMilestone.value,
                            items: milestoneController.milestoneNames,
                            onChanged: (v) =>
                                controller.onAffectedMilestoneChanged(index, v),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select an affected milestone'
                                : null,
                            hint: 'Select Milestone',
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        _buildTextFormField(
                          label: 'Brief Details *',
                          initialValue: fs.briefDetails.value,
                          onChanged: (v) =>
                              controller.onBriefDetailsChanged(index, v),
                          hint: 'Detail',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter brief details'
                              : null,
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        _buildDateField(
                          label: 'Issue Open Date *',
                          selectedDate: fs.issueOpenDate.value,
                          onDateChanged: (date) =>
                              controller.onIssueOpenDateChanged(index, date),
                          hint: 'Enter Date',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        Obx(
                          () => _buildDropdownField(
                            label: 'Role *',
                            value: fs.role.value,
                            items: doerRoleController.doerRoleNames,
                            onChanged: (v) =>
                                controller.onRoleChanged(index, v),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select a role'
                                : null,
                            hint: 'Select Doer',
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        Obx(
                          () => _buildAttachmentField(
                            label: 'Attachment',
                            fileName: fs.attachmentFileName.value,
                            onAttachmentPicked: () =>
                                controller.pickAttachment(index),
                            hint: 'Choose File',
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // Delete Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.removeFieldSet(index),
                            tooltip: 'Delete row',
                          ),
                        ),

                        if (index < controller.fieldSets.length - 1)
                          Divider(color: AppColors.grey, thickness: 1),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                      ],
                    );
                  },
                ),
              ),

              // Add More Button
              ElevatedButton(
                onPressed: controller.addFieldSet,
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  'Add More',
                  style: AppStyle.buttonTextPoppinsWhite.responsive,
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

              // Submit Button
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
    print(fileName);
    TextEditingController fcontroller = TextEditingController(text: fileName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAttachmentPicked,
          child: AbsorbPointer(
            child: TextFormField(
              controller: fcontroller,
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
