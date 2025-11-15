import 'dart:convert';
import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/add_pboq_measurment/get_add_pboq_measurment_response.dart';
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
  var planningStatus = 'Not Started'.obs;
  var subLocation = ''.obs;
  var uom = 'Unit'.obs;
  var nos = ''.obs;
  var length = ''.obs;
  var breadth = ''.obs;
  var height = ''.obs;
  var remark = ''.obs;
  var calculatedQty = '0'.obs;
  late final TextEditingController calculatedQtyController;

  FieldSet() {
    calculatedQtyController = TextEditingController();
    // Listen to calculatedQty changes and update controller
    ever(calculatedQty, (value) {
      calculatedQtyController.text = value;
    });
  }

  void calculateQuantity() {
    // Parse inputs, treat empty string as null (not 0)
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

    // Collect non-null values
    final List<double> values = [
      if (nosVal != null) nosVal,
      if (lengthVal != null) lengthVal,
      if (breadthVal != null) breadthVal,
      if (heightVal != null) heightVal,
    ];

    // If no valid values, result = 0
    if (values.isEmpty) {
      calculatedQty.value = '0.00';
      log('CALCULATION → No valid inputs', name: 'FieldSet');
      return;
    }

    // Multiply all available values
    double result = values.reduce((a, b) => a * b);

    calculatedQty.value = result.toStringAsFixed(2);

    // Log which fields were used
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

class AddPboqFormController extends GetxController {
  // Global selections
  var selectedPackage = ''.obs;
  var selectedPboqName = ''.obs;
  RxString uom = "".obs;

  // Dynamic field sets
  var fieldSets = <FieldSet>[FieldSet()].obs;

  // Injected controllers
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

  // Planning status options
  final List<String> planningStatusOptions = [
    'Not Started',
    'In Progress',
    'Completed',
    'On Hold',
  ];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context != null) {
        // Auto-bind Package
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

        // Fetch PBOQs
        await _pboqCtrl.fetchPboqs(
          forceFetch: true,
          context: Get.context!,
          projectId: mesurmentCtrl.projectId.value,
          packageId: mesurmentCtrl.packageId.value,
        );

        // Auto-bind PBOQ
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

  // Getters
  List<String> get packageNames => _pkgCtrl.packageNames;
  List<String> get pboqNames => _pboqCtrl.pboqNames;
  List<String> get zoneNames => _zoneCtrl.zoneNames;
  List<String> get zoneLocations => _zoneLocationCtrl.zoneLocationNames;

  // Reset helper
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
      for (final fs in fieldSets) {
        fs.selectedZone.value = '';
        fs.selectedLocation.value = '';
        fs.subLocation.value = '';
        fs.nos.value = '';
        fs.length.value = '';
        fs.breadth.value = '';
        fs.height.value = '';
        fs.remark.value = '';
        fs.planningStatus.value = 'Not Started';
        fs.uom.value = uom.value;
      }
    }
  }

  // Package changed
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

  // PBOQ changed
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
  }

  // Zone changed per row
  void onFieldZoneChanged(int index, String? value) async {
    fieldSets[index].selectedZone.value = value ?? '';
    fieldSets[index].selectedLocation.value = '';

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

    fieldSets.refresh();
  }

  // Location changed
  void onFieldLocationChanged(int index, String? value) {
    fieldSets[index].selectedLocation.value = value ?? '';
  }

  // Planning status
  void onPlanningStatusChanged(int index, String? value) {
    fieldSets[index].planningStatus.value = value ?? 'Not Started';
  }

  // Text field handlers
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

  // Add new row
  void addFieldSet() {
    fieldSets.add(FieldSet());
  }

  // DELETE ROW - NEW METHOD
  void removeFieldSet(int index) {
    if (fieldSets.length > 1) {
      fieldSets.removeAt(index);
    } else {
      // Always keep at least one row — clear instead of delete
      final fs = fieldSets[0];
      fs.selectedZone.value = '';
      fs.selectedLocation.value = '';
      fs.subLocation.value = '';
      fs.nos.value = '';
      fs.length.value = '';
      fs.breadth.value = '';
      fs.height.value = '';
      fs.remark.value = '';
      fs.planningStatus.value = 'Not Started';
      fs.uom.value = uom.value;
      fs.calculateQuantity();
    }
  }

  // Refresh
  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    resetForm();
  }

  // API Call
  Future<void> addPboqMeasurment({BuildContext? context}) async {
    try {
      final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);

      final List<Map<String, dynamic>> zonesData = fieldSets.map((fs) {
        final String? zoneId = _zoneCtrl.getZoneIdByName(fs.selectedZone.value);
        final String? locationId = _zoneLocationCtrl.getZoneLocationIdByName(
          fs.selectedLocation.value,
        );

        return {
          "zone_id": int.tryParse(zoneId ?? '0') ?? 0,
          "zone_location_id": int.tryParse(locationId ?? '0') ?? 0,
          "sub_location": fs.subLocation.value,
          "nos": double.tryParse(fs.nos.value) ?? 0,
          "length": double.tryParse(fs.length.value) ?? 0,
          "bredth": double.tryParse(fs.breadth.value) ?? 0,
          "height": double.tryParse(fs.height.value) ?? 0,
          "remark": fs.remark.value,
        };
      }).toList();

      final jsonBody = {
        "project_id": mesurmentCtrl.projectId.value,
        "pboq_id": pboqId ?? "",
        "zones_data": zonesData,
      };

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.addMeasurementSheetApi,
        Networkutility.addMeasurementSheet,
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
            message: 'PBOQ Measurement Sheet added successfully!',
          );
          Get.offNamed(AppRoutes.pboqList);
        } else {
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to add measurement sheet.");

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

  // Submit
  void submitForm() {
    if (selectedPackage.isEmpty) {
      Get.snackbar('Error', 'Please select a package');
      return;
    }
    if (selectedPboqName.isEmpty) {
      Get.snackbar('Error', 'Please select a PBOQ');
      return;
    }

    for (int i = 0; i < fieldSets.length; i++) {
      final f = fieldSets[i];
      if (f.selectedZone.isEmpty) {
        Get.snackbar('Error', 'Select zone for row ${i + 1}');
        return;
      }
      if (f.selectedLocation.isEmpty) {
        Get.snackbar('Error', 'Select location for row ${i + 1}');
        return;
      }
    }

    addPboqMeasurment();
  }

  // Reset
  void resetForm() {
    selectedPackage.value = '';
    selectedPboqName.value = '';
    fieldSets.clear();
    fieldSets.add(FieldSet());
    _resetDependents(resetPboq: true, resetZone: true, resetLocation: true);
  }
}
