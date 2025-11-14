import 'package:ashishinterbuild/app/common/custominputformatters/securetext_input_formatter.dart';
import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/add_pboq/add_pboq_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
              // PACKAGE NAME - READ ONLY
              Obx(
                () => _buildDropdownField(
                  label: 'Package Name',
                  value: controller.selectedPackage.value,
                  items: controller.packageNames,
                  onChanged: null, // Disabled
                  validator: null, // No validation needed for read-only
                  hint: 'Selected package',
                  enabled: false, // Fully disabled
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

              // PBOQ NAME - Editable
              Obx(
                () => _buildDropdownField(
                  label: 'PBOQ Name',
                  value: controller.selectedPboqName.value,
                  items: controller.pboqNames,
                  onChanged: controller.onPboqNameChanged,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a PBOQ name'
                      : null,
                  hint: 'Select a PBOQ name',
                  enabled: false,
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              Divider(color: AppColors.darkBackground),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

              // DYNAMIC FIELD SETS
              Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.fieldSets.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        // ZONE
                        Obx(
                          () => _buildDropdownField(
                            label: 'Zone',
                            value: controller.selectedZoneName.value,
                            items: controller.zoneNames,
                            onChanged: (value) =>
                                controller.onZoneChanged(value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select a zone'
                                : null,
                            hint: 'Select a zone',
                            enabled: true,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // PLANNING STATUS (Read-only)
                        _buildTextFormField(
                          label: 'Planning Status',
                          initialValue:
                              controller.fieldSets[index].planningStatus.value,
                          onChanged: null,
                          hint: 'Planning status',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // LOCATION
                        Obx(
                          () => _buildDropdownField(
                            label: 'Location',
                            value: controller.selectedZoneLocationName.value,
                            items: controller.zoneLocations,
                            onChanged: (value) =>
                                controller.onLocationChanged(value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select a location'
                                : null,
                            hint: 'Select a location',
                            enabled: true,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // SUB LOCATION
                        _buildTextFormField(
                          label: 'Sub Location',
                          initialValue:
                              controller.fieldSets[index].subLocation.value,
                          onChanged: (value) =>
                              controller.onSubLocationChanged(index, value),
                          hint: 'Enter sub location',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // UOM (Read-only)
                        _buildTextFormField(
                          label: 'UOM',
                          initialValue: controller.fieldSets[index].uom.value,
                          onChanged: null,
                          hint: 'Unit of measure',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // NOS
                        _buildTextFormField(
                          label: 'Nos',
                          initialValue: controller.fieldSets[index].nos.value,
                          onChanged: (value) =>
                              controller.onNosChanged(index, value),
                          hint: 'Enter number of items',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // LENGTH
                        _buildTextFormField(
                          label: 'Length',
                          initialValue:
                              controller.fieldSets[index].length.value,
                          onChanged: (value) =>
                              controller.onLengthChanged(index, value),
                          hint: 'Enter length',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                        _buildTextFormField(
                          label: 'Breadth',
                          initialValue:
                              controller.fieldSets[index].length.value,
                          onChanged: (value) =>
                              controller.onLengthChanged(index, value),
                          hint: 'Enter Breadth',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                        // HEIGHT
                        _buildTextFormField(
                          label: 'Height',
                          initialValue:
                              controller.fieldSets[index].height.value,
                          onChanged: (value) =>
                              controller.onHeightChanged(index, value),
                          hint: 'Enter height',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),

                        // REMARK
                        _buildTextFormField(
                          label: 'Remark',
                          initialValue:
                              controller.fieldSets[index].remark.value,
                          onChanged: (value) =>
                              controller.onRemarkChanged(index, value),
                          hint: 'Enter remarks',
                        ),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
                        Divider(),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: ResponsiveHelper.screenHeight * 0.02),
              ElevatedButton(
                onPressed: controller.addFieldSet,
                style: AppButtonStyles.elevatedLargeBlack(),
                child: Text(
                  "Add More",
                  style: AppStyle.buttonTextPoppinsWhite.responsive,
                ),
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.05),
              ElevatedButton(
                onPressed: controller.submitForm,
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
    );
  }

  // Updated Dropdown Field with 'enabled' support
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    String? Function(String?)? validator,
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
          validator: validator,
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

  // TextFormField (unchanged)
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

  // AppBar (unchanged)
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
