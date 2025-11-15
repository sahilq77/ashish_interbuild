import 'package:ashishinterbuild/app/common/custominputformatters/number_input_formatter.dart';
import 'package:ashishinterbuild/app/common/custominputformatters/securetext_input_formatter.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/add_pboq/add_pboq_form_controller.dart'
    hide FieldSet;
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/edit_pboq/edit_pboq_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditPboqFormView extends StatefulWidget {
  const EditPboqFormView({super.key});

  // Helper to parse field values and get used dimensions
  static Map<String, double?> _parseFieldValues(FieldSet fs) {
    return {
      'Nos': fs.nos.value.isEmpty ? null : double.tryParse(fs.nos.value),
      'L': fs.length.value.isEmpty ? null : double.tryParse(fs.length.value),
      'B': fs.breadth.value.isEmpty ? null : double.tryParse(fs.breadth.value),
      'H': fs.height.value.isEmpty
          ? null
          : double.tryParse(fs.height.value) ?? 1,
    };
  }

  // Build dynamic label like "Calculated Qty (Nos × L × B)"
  static String _buildDynamicLabel(FieldSet fs) {
    final values = _parseFieldValues(fs);
    final activeKeys = <String>[];

    if (values['Nos'] != null) activeKeys.add('Nos');
    if (values['L'] != null) activeKeys.add('L');
    if (values['B'] != null) activeKeys.add('B');

    // Show H if explicitly entered OR defaulted when others exist
    final bool hasOtherFields = activeKeys.isNotEmpty;
    final bool heightExplicit = values['H'] != null && !fs.height.value.isEmpty;
    final bool heightDefault =
        values['H'] == 1.0 && fs.height.value.isEmpty && hasOtherFields;

    if (heightExplicit || heightDefault) {
      activeKeys.add('H');
    }

    return activeKeys.isEmpty ? '—' : activeKeys.join(' × ');
  }

  @override
  State<EditPboqFormView> createState() => _AddPboqFormViewState();
}

class _AddPboqFormViewState extends State<EditPboqFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final EditPboqFormController controller = Get.put(EditPboqFormController());
    final PboqMeasurmentDetailController conditionCtrl = Get.find();

    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
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

                // Dynamic Field Sets (Only ONE row, no add/delete)
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.fieldSets.length,
                    itemBuilder: (ctx, index) {
                      final fs = controller.fieldSets[index];

                      return Column(
                        children: [
                          // Zone *
                          Obx(() {
                            final fs = controller.fieldSets[index];
                            final bool zoneError =
                                fs.selectedZone.value.isEmpty;
                            final bool locationError =
                                fs.selectedLocation.value.isEmpty;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Zone *
                                _buildDropdownField(
                                  label: 'Zone *',
                                  value: fs.selectedZone.value,
                                  items: controller.zoneNames,
                                  onChanged: (v) =>
                                      controller.onFieldZoneChanged(index, v),
                                  hint: 'Select zone',
                                  enabled: true,
                                  errorText: zoneError
                                      ? 'Zone is required'
                                      : null,
                                ),

                                const SizedBox(height: 12),
                                // Location *
                                _buildDropdownField(
                                  label: 'Location *',
                                  value: fs.selectedLocation.value,
                                  items: controller.zoneLocations,
                                  onChanged: (v) => controller
                                      .onFieldLocationChanged(index, v),
                                  hint: 'Select location',
                                  enabled: true,
                                  errorText: locationError
                                      ? 'Location is required'
                                      : null,
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 12),

                          // Sub Location
                          _buildTextFormField(
                            label: 'Sub Location *',
                            initialValue: fs.subLocation.value,
                            onChanged: (v) =>
                                controller.onSubLocationChanged(index, v),
                            hint: 'Enter sub-location',
                            readOnly: false,
                            inputFormatters: [SecureTextInputFormatter.deny()],
                          ),
                          const SizedBox(height: 12),

                          // UOM
                          // _buildTextFormField(
                          //   label: 'UOM',
                          //   initialValue: fs.uom.value,
                          //   onChanged: null,
                          //   hint: 'Unit',
                          //   readOnly: true,
                          // ),
                          // const SizedBox(height: 12),

                          // Nos
                          _buildTextFormField(
                            label: 'Nos *',
                            initialValue: fs.nos.value,
                            onChanged: (v) => controller.onNosChanged(index, v),
                            hint: 'Enter number',
                            readOnly: false,
                            inputFormatters: [
                              SecureTextInputFormatter.deny(),
                              NumberInputFormatter(),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Length
                          Obx(
                            () => _buildTextFormField(
                              label: 'Length *',
                              initialValue: fs.length.value,
                              onChanged: (v) =>
                                  controller.onLengthChanged(index, v),
                              hint: 'Enter length',
                              readOnly: conditionCtrl.lengthEnabled.value == 1,
                              inputFormatters: [
                                SecureTextInputFormatter.deny(),
                                NumberInputFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Breadth
                          Obx(
                            () => _buildTextFormField(
                              label: 'Breadth *',
                              initialValue: fs.breadth.value,
                              onChanged: (v) =>
                                  controller.onBreadthChanged(index, v),
                              hint: 'Enter breadth',
                              readOnly: conditionCtrl.breadthEnabled.value == 1,
                              inputFormatters: [
                                SecureTextInputFormatter.deny(),
                                NumberInputFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Height
                          Obx(
                            () => _buildTextFormField(
                              label: 'Height *',
                              initialValue: fs.height.value,
                              onChanged: (v) =>
                                  controller.onHeightChanged(index, v),
                              hint: 'Enter height',
                              readOnly: conditionCtrl.heightEnabled.value == 1,
                              inputFormatters: [
                                SecureTextInputFormatter.deny(),
                                NumberInputFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Calculated Qty — Dynamic Label
                          Obx(() {
                            final formula = EditPboqFormView._buildDynamicLabel(
                              fs,
                            );
                            return _buildTextFormFieldWithController(
                              label: 'Calculated Qty ($formula)',
                              controller: fs.calculatedQtyController,
                              hint: 'Auto-calculated',
                              readOnly: true,
                            );
                          }),
                          const SizedBox(height: 12),
                          Obx(
                            () => _buildTextFormField(
                              label: 'Deduction ',
                              initialValue: fs.height.value,
                              onChanged: (v) =>
                                  controller.onHeightChanged(index, v),
                              hint: 'Deduction value',
                              readOnly: true,
                              inputFormatters: [
                                SecureTextInputFormatter.deny(),
                              ],
                            ),
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
                            inputFormatters: [SecureTextInputFormatter.deny()],
                          ),

                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),

                // ADD MORE BUTTON REMOVED

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.submitForm();
                    }
                  },
                  style: AppButtonStyles.elevatedLargeBlack(),
                  child: Text(
                    'Submit',
                    style: AppStyle.buttonTextPoppinsWhite.responsive,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Note: (if any deductions have already been applied, unit calculations and quantity values may not match)(also, if you update any values from L / B / H / Nos, all previous deductions will be automatically removed)",
                  style: AppStyle.reportCardSubTitle.responsive,
                ),

                const SizedBox(height: 40),
              ],
            ),
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
    String? errorText,
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
              errorText: errorText,
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
    required List<TextInputFormatter> inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          initialValue: initialValue,
          onChanged: onChanged,
          enabled: onChanged != null,
          validator: label.contains('*') && !readOnly
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${label.replaceAll('*', '').trim()} is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
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

  // Text Field with Controller
  Widget _buildTextFormFieldWithController({
    required String label,
    required TextEditingController controller,
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
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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

  // AppBar
  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Edit PBOQ Measurement Details',
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
