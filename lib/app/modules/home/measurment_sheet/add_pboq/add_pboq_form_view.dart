import 'package:ashishinterbuild/app/common/custominputformatters/securetext_input_formatter.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/add_pboq/add_pboq_form_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPboqFormView extends StatelessWidget {
  const AddPboqFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final AddPboqFormController controller = Get.put(AddPboqFormController());
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
              // Package (read-only)
              Obx(
                () => _buildDropdownField(
                  label: 'Package Name',
                  value: controller.selectedPackage.value,
                  items: controller.packageNames,
                  onChanged: null,
                  hint: 'Selected package',
                  enabled: false,
                ),
              ),
              const SizedBox(height: 16),

              // PBOQ (read-only)
              Obx(
                () => _buildDropdownField(
                  label: 'PBOQ Name',
                  value: controller.selectedPboqName.value,
                  items: controller.pboqNames,
                  onChanged: null,
                  hint: 'Selected PBOQ',
                  enabled: false,
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: AppColors.darkBackground,
                thickness: ResponsiveHelper.spacing(2),
              ),
              const SizedBox(height: 16),

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
                        // Zone Dropdown
                        Obx(
                          () => _buildDropdownField(
                            label: 'Zone',
                            value: fs.selectedZone.value,
                            items: controller.zoneNames,
                            onChanged: (v) =>
                                controller.onFieldZoneChanged(index, v),
                            hint: 'Select zone',
                            enabled: true,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Planning Status Dropdown
                        Obx(
                          () => _buildDropdownField(
                            label: 'Planning Status',
                            value: fs.planningStatus.value,
                            items: controller.planningStatusOptions,
                            onChanged: (v) =>
                                controller.onPlanningStatusChanged(index, v),
                            hint: 'Select status',
                            enabled: false,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Location Dropdown
                        Obx(
                          () => _buildDropdownField(
                            label: 'Location',
                            value: fs.selectedLocation.value,
                            items: controller.zoneLocations,
                            onChanged: (v) =>
                                controller.onFieldLocationChanged(index, v),
                            hint: 'Select location',
                            enabled: true,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Sub Location
                        _buildTextFormField(
                          label: 'Sub Location',
                          initialValue: fs.subLocation.value,
                          onChanged: (v) =>
                              controller.onSubLocationChanged(index, v),
                          hint: 'Enter sub-location',
                          readOnly: false,
                        ),
                        const SizedBox(height: 12),

                        // UOM (read-only)
                        _buildTextFormField(
                          label: 'UOM',
                          initialValue: fs.uom.value,
                          onChanged: null,
                          hint: 'Unit',
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),

                        // Nos
                        _buildTextFormField(
                          label: 'Nos',
                          initialValue: fs.nos.value,
                          onChanged: (v) => controller.onNosChanged(index, v),
                          hint: 'Enter number',
                          readOnly: false,
                        ),
                        const SizedBox(height: 12),

                        // Length
                        _buildTextFormField(
                          label: 'Length',
                          initialValue: fs.length.value,
                          onChanged: (v) =>
                              controller.onLengthChanged(index, v),
                          hint: 'Enter length',
                          readOnly: controller.lengthEnabled == 1 ? true : false,
                        ),
                        const SizedBox(height: 12),

                        // Breadth
                        _buildTextFormField(
                          label: 'Breadth',
                          initialValue: fs.breadth.value,
                          onChanged: (v) =>
                              controller.onBreadthChanged(index, v),
                          hint: 'Enter breadth',
                          readOnly: controller.breadthEnabled == 1
                              ? true
                              : false,
                        ),
                        const SizedBox(height: 12),

                        // Height
                        _buildTextFormField(
                          label: 'Height',
                          initialValue: fs.height.value,
                          onChanged: (v) =>
                              controller.onHeightChanged(index, v),
                          hint: 'Enter height',
                          readOnly: controller.heightEnabled == 1
                              ? true
                              : false,
                        ),
                        const SizedBox(height: 12),

                        // Remark
                        _buildTextFormField(
                          label: 'Remark',
                          initialValue: fs.remark.value,
                          onChanged: (v) =>
                              controller.onRemarkChanged(index, v),
                          hint: 'Enter remarks',
                          readOnly: false,
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: AppColors.grey,
                          thickness: ResponsiveHelper.spacing(2),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),

              // Buttons
              ElevatedButton(
                onPressed: controller.addFieldSet,
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  'Add More',
                  style: AppStyle.buttonTextPoppinsWhite.responsive,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.submitForm,
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  'Submit',
                  style: AppStyle.buttonTextPoppinsWhite.responsive,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    required String hint,
    bool enabled = true,
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
          enabled: enabled,
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
              filled: !enabled,
              fillColor: !enabled ? Colors.grey[200] : null,
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

  // Text Field
  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required Function(String)? onChanged,
    required String hint,
    required bool readOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: readOnly,
          inputFormatters: [SecureTextInputFormatter.deny()],
          initialValue: initialValue,
          onChanged: onChanged,
          enabled: onChanged != null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: onChanged == null,
            fillColor: onChanged == null ? Colors.grey[200] : null,
          ),
        ),
      ],
    );
  }

  // AppBar
  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Add PBOQ Measurement Details',
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
