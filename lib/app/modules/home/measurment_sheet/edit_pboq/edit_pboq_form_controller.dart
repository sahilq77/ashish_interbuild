import 'dart:convert';
import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_add_pboq_measurment_response.dart';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_planning_status_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_edit_pboq_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_measurmentsheet_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/network/network_utility.dart';

class FieldSet {
  var selectedZone = ''.obs;
  var selectedLocation = ''.obs;
  var planningStatus = ''.obs;
  var subLocation = ''.obs;
  var uom = ''.obs;
  var nos = ''.obs;
  var length = ''.obs;
  var breadth = ''.obs;
  var height = ''.obs;
  var remark = ''.obs;
  var deduction = ''.obs;
  var calculatedQty = '0'.obs;
  late final TextEditingController calculatedQtyController;
  late final TextEditingController subLocationController;
  late final TextEditingController nosController;
  late final TextEditingController lengthController;
  late final TextEditingController breadthController;
  late final TextEditingController heightController;
  late final TextEditingController remarkController;
  late final TextEditingController deductionController;

  FieldSet() {
    calculatedQtyController = TextEditingController();
    subLocationController = TextEditingController();
    nosController = TextEditingController();
    lengthController = TextEditingController();
    breadthController = TextEditingController();
    heightController = TextEditingController();
    remarkController = TextEditingController();
    deductionController = TextEditingController();

    // Listen to observable changes and update controllers
    ever(calculatedQty, (value) => calculatedQtyController.text = value);
    ever(subLocation, (value) => subLocationController.text = value);
    ever(nos, (value) => nosController.text = value);
    ever(length, (value) => lengthController.text = value);
    ever(breadth, (value) => breadthController.text = value);
    ever(height, (value) => heightController.text = value);
    ever(remark, (value) => remarkController.text = value);
    ever(deduction, (value) => deductionController.text = value);
  }

  void calculateQuantity() {
    final double? nosVal = nos.value.isEmpty
        ? null
        : double.tryParse(nos.value);
    final double? lengthVal = length.value.isEmpty
        ? null
        : double.tryParse(length.value);
    final double? breadthVal = breadth.value.isEmpty
        ? null
        : double.tryParse(breadth.value);
    final double? heightVal = height.value.isEmpty
        ? null
        : double.tryParse(height.value) ?? 1;

    final List<double> values = [
      if (nosVal != null) nosVal,
      if (lengthVal != null) lengthVal,
      if (breadthVal != null) breadthVal,
      if (heightVal != null) heightVal,
    ];

    if (values.isEmpty) {
      calculatedQty.value = '0.00';
      log('CALCULATION → No valid inputs', name: 'FieldSet');
      return;
    }

    double result = values.reduce((a, b) => a * b);
    calculatedQty.value = result.toStringAsFixed(2);

    final usedFields = <String>[
      if (nosVal != null) 'Nos:$nosVal',
      if (lengthVal != null) 'L:$lengthVal',
      if (breadthVal != null) 'B:$breadthVal',
      if (heightVal != null) 'H:$heightVal',
    ].join(' × ');

    log(
      'CALCULATION → $usedFields = $result (formatted: ${calculatedQty.value})',
      name: 'FieldSet',
    );
  }
}

class EditPboqFormController extends GetxController {
  var selectedPackage = ''.obs;
  var selectedPboqName = ''.obs;
  RxString uom = "".obs;

  var fieldSets = <FieldSet>[].obs;

  final PboqMeasurmentDetailController PBOQMSctr = Get.put(
    PboqMeasurmentDetailController(),
  );
  final MeasurementSheetController mesurmentCtrl = Get.find();
  late final PackageNameController _pkgCtrl = Get.find<PackageNameController>();
  late final PboqNameController _pboqCtrl = Get.find<PboqNameController>();
  late final ZoneController _zoneCtrl = Get.find<ZoneController>();
  late final ZoneLocationController _zoneLocationCtrl =
      Get.find<ZoneLocationController>();
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString errorMessage = ''.obs;
  RxMap<int, PlanningStatus> planningStatusData = <int, PlanningStatus>{}.obs;

  List<String> get packageNames => _pkgCtrl.packageNames;
  List<String> get pboqNames => _pboqCtrl.pboqNames;
  List<String> get zoneNames => _zoneCtrl.zoneNames;
  List<String> get zoneLocations => _zoneLocationCtrl.zoneLocationNames;

  void _resetDependents({
    bool resetPboq = false,
    bool resetZone = false,
    bool resetLocation = false,
    bool resetFieldSets = false,
  }) {
    if (resetPboq) {
      selectedPboqName.value = '';
      _pboqCtrl.pboqNames.clear();
    }
    if (resetZone) {
      _zoneCtrl.zoneNames.clear();
    }
    if (resetLocation) {
      _zoneLocationCtrl.zoneLocationNames.clear();
    }
    if (resetFieldSets && fieldSets.isNotEmpty) {
      final fs = fieldSets[0];
      fs.selectedZone.value = '';
      fs.selectedLocation.value = '';
      fs.subLocation.value = '';
      fs.nos.value = '';
      fs.length.value = '';
      fs.breadth.value = '';
      fs.height.value = '';
      fs.remark.value = '';
      fs.planningStatus.value = '';
      fs.uom.value = PBOQMSctr.uom.value.isNotEmpty
          ? PBOQMSctr.uom.value
          : 'Unit';
    }
  }

  void onPackageChanged(String? newPackageName) async {
    selectedPackage.value = newPackageName ?? '';
    _resetDependents(
      resetPboq: true,
      resetZone: true,
      resetLocation: true,
      resetFieldSets: true,
    );

    final String? pkgId = _pkgCtrl.getPackageIdByName(newPackageName ?? '');
    if (pkgId == null) return;

    await _pboqCtrl.fetchPboqs(
      forceFetch: true,
      context: Get.context!,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.tryParse(pkgId) ?? 0,
    );
  }

  void onPboqNameChanged(String? value) async {
    selectedPboqName.value = value ?? '';
    _resetDependents(
      resetZone: true,
      resetLocation: true,
      resetFieldSets: true,
    );

    final String? pboqId = _pboqCtrl.getPboqIdByName(value ?? '');
    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);
    if (pboqId == null || pkgId == null) return;

    await _zoneCtrl.fetchZones(
      forceFetch: true,
      context: Get.context!,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.tryParse(pkgId) ?? 0,
      pboqId: int.tryParse(pboqId) ?? 0,
    );

    for (final fs in fieldSets) {
      fs.uom.value = PBOQMSctr.uom.value.isNotEmpty
          ? PBOQMSctr.uom.value
          : 'Unit';
    }
  }

  void onFieldZoneChanged(int index, String? value) async {
    fieldSets[index].selectedZone.value = value ?? '';
    fieldSets[index].selectedLocation.value = '';
    fieldSets[index].planningStatus.value = '';

    final String? zoneId = _zoneCtrl.getZoneIdByName(value ?? '');
    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);
    final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);

    if (zoneId == null || pkgId == null || pboqId == null) return;

    await _zoneLocationCtrl.fetchZoneLocations(
      context: Get.context!,
      forceFetch: true,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.tryParse(pkgId) ?? 0,
      pboqId: int.tryParse(pboqId) ?? 0,
      zoneId: int.tryParse(zoneId) ?? 0,
    );

    await fetchPlanningStatusForZone(int.tryParse(zoneId) ?? 0, index);

    fieldSets.refresh();
  }

  void onFieldLocationChanged(int index, String? value) {
    fieldSets[index].selectedLocation.value = value ?? '';
  }

  void onPlanningStatusChanged(int index, String? value) {
    fieldSets[index].planningStatus.value = value ?? 'Not Started';
  }

  void onSubLocationChanged(int index, String value) {
    fieldSets[index].subLocation.value = value;
  }

  void onNosChanged(int index, String value) {
    fieldSets[index].nos.value = value;
    fieldSets[index].calculateQuantity();
  }

  void onLengthChanged(int index, String value) {
    fieldSets[index].length.value = value;
    fieldSets[index].calculateQuantity();
  }

  void onBreadthChanged(int index, String value) {
    fieldSets[index].breadth.value = value;
    fieldSets[index].calculateQuantity();
  }

  void onHeightChanged(int index, String value) {
    fieldSets[index].height.value = value;
    fieldSets[index].calculateQuantity();
  }

  void onRemarkChanged(int index, String value) {
    fieldSets[index].remark.value = value;
  }

  // Store selected item data for auto-binding
  var selectedMsId = ''.obs;
  var selectedItemData = Rxn<AllData>();
  var argumentValues = <String, String>{}.obs;

  void _storeArgumentValues(Map<String, dynamic> args) {
    argumentValues['zone_name'] = args['zone_name'] ?? '';
    argumentValues['location_name'] = args['location_name'] ?? '';
    argumentValues['sub_location'] = args['sub_location'] ?? '';
    argumentValues['nos'] = args['nos'] ?? '';
    argumentValues['length'] = args['length'] ?? '';
    argumentValues['breadth'] = args['breadth'] ?? '';
    argumentValues['height'] = args['height'] ?? '';
    argumentValues['remark'] = args['remark'] ?? '';
    argumentValues['deduction'] = args['deduction'] ?? '';
  }

  @override
  void onInit() {
    super.onInit();

    // Get selected item data from arguments
    final args = Get.arguments as Map<String, dynamic>?;

    // LOG ARGUMENTS
    if (args != null) {
      log(
        'Arguments received in EditPboqFormController: ${jsonEncode(args)}',
        name: 'EditPboqFormController',
      );
    } else {
      log(
        'No arguments passed to EditPboqFormController',
        name: 'EditPboqFormController',
      );
    }

    if (args != null) {
      selectedMsId.value = args['ms_id'] ?? '';
      if (args['selected_item'] != null) {
        selectedItemData.value = args['selected_item'] as AllData;
      }
      // Store individual field values for easier access
      _storeArgumentValues(args);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context != null) {
        await _pkgCtrl
            .fetchPackages(
              context: Get.context!,
              projectId: mesurmentCtrl.projectId.value,
            )
            .then((_) {
              final String? autoPackageId = mesurmentCtrl.packageId.value
                  .toString();
              if (autoPackageId != null &&
                  autoPackageId != 'null' &&
                  autoPackageId.isNotEmpty) {
                final String? packageName = _pkgCtrl.getPackageNameById(
                  autoPackageId,
                );
                if (packageName != null && packageName.isNotEmpty) {
                  selectedPackage.value = packageName;
                  onPackageChanged(packageName);
                }
              }
            });

        await _pboqCtrl.fetchPboqs(
          forceFetch: true,
          context: Get.context!,
          projectId: mesurmentCtrl.projectId.value,
          packageId: mesurmentCtrl.packageId.value,
        );

        // Always ensure exactly ONE field set
        fieldSets.clear();
        final initialFieldSet = FieldSet();
        initialFieldSet.uom.value = PBOQMSctr.uom.value.isNotEmpty
            ? PBOQMSctr.uom.value
            : 'Unit';
        fieldSets.add(initialFieldSet);

        final String? autoPboqId = PBOQMSctr.pboqId.value.toString();
        if (autoPboqId != null &&
            autoPboqId != 'null' &&
            autoPboqId.isNotEmpty) {
          final String? pboqName = _pboqCtrl.getPboqNameById(autoPboqId);
          if (pboqName != null && pboqName.isNotEmpty) {
            selectedPboqName.value = pboqName;
            onPboqNameChanged(pboqName);
          }
        }

        // Auto-bind selected item data if arguments exist
        if (argumentValues.isNotEmpty) {
          _bindSelectedItemData();
        }
      }
    });
  }

  void _bindSelectedItemData() async {
    log('Starting _bindSelectedItemData', name: 'EditPboqFormController');
    log(
      'ArgumentValues: ${argumentValues.toString()}',
      name: 'EditPboqFormController',
    );

    // First load zones and locations
    final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);
    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);

    log('PBOQ ID: $pboqId, Package ID: $pkgId', name: 'EditPboqFormController');

    if (pboqId != null && pkgId != null) {
      await _zoneCtrl.fetchZones(
        forceFetch: true,
        context: Get.context!,
        projectId: mesurmentCtrl.projectId.value,
        packageId: int.tryParse(pkgId) ?? 0,
        pboqId: int.tryParse(pboqId) ?? 0,
      );

      log(
        'Available zones: ${_zoneCtrl.zoneNames}',
        name: 'EditPboqFormController',
      );

      // Then bind the data from arguments
      if (fieldSets.isEmpty) {
        log(
          'No fieldSets available for binding',
          name: 'EditPboqFormController',
        );
        return;
      }
      final fs = fieldSets[0];
      fs.selectedZone.value = argumentValues['zone_name'] ?? '';

      log(
        'Setting zone to: ${argumentValues['zone_name']}',
        name: 'EditPboqFormController',
      );

      // Load locations for the selected zone
      final String? zoneId = _zoneCtrl.getZoneIdByName(
        argumentValues['zone_name'] ?? '',
      );

      log('Zone ID found: $zoneId', name: 'EditPboqFormController');

      if (zoneId != null) {
        await _zoneLocationCtrl.fetchZoneLocations(
          context: Get.context!,
          forceFetch: true,
          projectId: mesurmentCtrl.projectId.value,
          packageId: int.tryParse(pkgId) ?? 0,
          pboqId: int.tryParse(pboqId) ?? 0,
          zoneId: int.tryParse(zoneId) ?? 0,
        );

        log(
          'Available locations: ${_zoneLocationCtrl.zoneLocationNames}',
          name: 'EditPboqFormController',
        );
      }

      fs.selectedLocation.value = argumentValues['location_name'] ?? '';
      fs.subLocation.value = argumentValues['sub_location'] ?? '';
      fs.nos.value = argumentValues['nos'] ?? '';
      fs.length.value = argumentValues['length'] ?? '';
      fs.breadth.value = argumentValues['breadth'] ?? '';
      fs.height.value = argumentValues['height'] ?? '';
      fs.remark.value = argumentValues['remark'] ?? '';
      fs.deduction.value = argumentValues['deduction'] ?? '';

      log(
        'Binding complete. Zone: ${fs.selectedZone.value}, Location: ${fs.selectedLocation.value}',
        name: 'EditPboqFormController',
      );

      // Calculate quantity
      fs.calculateQuantity();

      // Force UI refresh
      fieldSets.refresh();
    } else {
      log(
        'Cannot bind data - missing PBOQ ID or Package ID',
        name: 'EditPboqFormController',
      );
    }
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    resetForm();
  }

  Future<void> editPboqMeasurment({BuildContext? context}) async {
    try {
      final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);
      final fs = fieldSets[0];
      final String? zoneId = _zoneCtrl.getZoneIdByName(fs.selectedZone.value);
      final String? locationId = _zoneLocationCtrl.getZoneLocationIdByName(
        fs.selectedLocation.value,
      );

      final jsonBody = {
        "project_id": mesurmentCtrl.projectId.value,
        "pboq_id": pboqId ?? "",
        "ms_id": selectedMsId.value,
        "zone_id": zoneId ?? "",
        "zone_location_id": locationId ?? "",
        "sub_location": fs.subLocation.value,
        "nos": fs.nos.value,
        "length": fs.length.value,
        "breadth": fs.breadth.value,
        "height": fs.height.value,
        "remark": fs.remark.value,
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.editMeasurementSheetApi,
        Networkutility.editMeasurementSheet,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetEditPboqMeasurmentResponse> response =
            getEditPboqMeasurmentResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: 'PBOQ Measurement Sheet edited successfully!',
          );
          Get.offNamed(AppRoutes.pboqList);
        } else {
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to edit measurement sheet.");

          AppSnackbarStyles.showError(title: 'Failed', message: errorMessage);
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Failed',
          message: "No response from server",
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'Unexpected Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void submitForm() {
    for (int i = 0; i < fieldSets.length; i++) {
      final f = fieldSets[i];
      if (f.selectedZone.isEmpty) {
        Get.snackbar('Error', 'Select zone');
        return;
      }
      if (f.selectedLocation.isEmpty) {
        Get.snackbar('Error', 'Select location');
        return;
      }
    }

    editPboqMeasurment();
  }

  Future<void> fetchPlanningStatusForZone(int zoneId, int fieldIndex) async {
    try {
      final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);
      if (pboqId == null) {
        log('PBOQ ID is null', name: 'EditPboqFormController');
        return;
      }

      final jsonBody = {
        "project_id": mesurmentCtrl.projectId.value,
        "pboq_id": pboqId,
        "zone_qty_data": [
          {"zone_id": zoneId, "qty": fieldSets[fieldIndex].calculatedQty.value},
        ],
      };

      log(
        'Fetching planning status for zone: $zoneId',
        name: 'EditPboqFormController',
      );

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.getPlanningStatusApi,
        Networkutility.getPlanningStatus,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetPlanningStatusResponse> response =
            getPlanningStatusResponseFromJson(jsonEncode(list));

        if (response[0].status == true && response[0].data.isNotEmpty) {
          final planningData = response[0].data[0];
          planningStatusData[zoneId] = planningData;

          final statusText =
              'Planned: ${planningData.plannedQty} | MS Qty: ${planningData.newMsQty}';
          fieldSets[fieldIndex].planningStatus.value = statusText;

          log(
            'Updated planning status: $statusText',
            name: 'EditPboqFormController',
          );

          fieldSets.refresh();
        } else {
          log(
            'API response status false or no data',
            name: 'EditPboqFormController',
          );
        }
      } else {
        log('Empty API response', name: 'EditPboqFormController');
      }
    } catch (e) {
      log('Error fetching planning status: $e', name: 'EditPboqFormController');
    }
  }

  void resetForm() {
    selectedPackage.value = '';
    selectedPboqName.value = '';
    fieldSets.clear();
    final newFieldSet = FieldSet();
    newFieldSet.uom.value = PBOQMSctr.uom.value.isNotEmpty
        ? PBOQMSctr.uom.value
        : 'Unit';
    fieldSets.add(newFieldSet);
    _resetDependents(resetPboq: true, resetZone: true, resetLocation: true);
  }
}
