import 'dart:convert';
import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_add_pboq_measurment_response.dart';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_planning_status_response.dart';
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
  var calculatedQty = '0'.obs;
  late final TextEditingController calculatedQtyController;

  FieldSet() {
    calculatedQtyController = TextEditingController();
    ever(calculatedQty, (value) {
      calculatedQtyController.text = value;
    });
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

  @override
  void onInit() {
    super.onInit();
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
      }
    });
  }

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
    if (resetFieldSets) {
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

  // ADD FIELDSET & REMOVE FIELDSET REMOVED

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    resetForm();
  }

  Future<void> editPboqMeasurment({BuildContext? context}) async {
    try {
      final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);

     

      final jsonBody = {
        "project_id": mesurmentCtrl.projectId.value,
        "pboq_id": pboqId ?? "",
        "ms_id": "",
        "zone_id": "",
        "zone_location_id": "",
        "sub_location": "",
        "nos": "",
        "length": "",
        "breadth": "",
        "height": "",
        "remark": "",
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.editMeasurementSheetApi,
        Networkutility.editMeasurementSheet,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetAddPboqMsResponse> response = getAddPboqMsResponseFromJson(
          jsonEncode(list),
        );

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
