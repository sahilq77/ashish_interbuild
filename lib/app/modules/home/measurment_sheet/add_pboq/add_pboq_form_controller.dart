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

  FieldSet();

  // Calculate quantity based on formula: Nos * Length * Breadth * Height
  void calculateQuantity() {
    final double nosVal = double.tryParse(nos.value) ?? 0;
    final double lengthVal = double.tryParse(length.value) ?? 0;
    final double breadthVal = double.tryParse(breadth.value) ?? 0;
    final double heightVal =
        double.tryParse(height.value) ?? 1; // Default to 1 if empty

    final double result = nosVal * lengthVal * breadthVal * heightVal;
    calculatedQty.value = result.toStringAsFixed(2);
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

  // Planning status options (customize as needed)
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

  // Getters for dropdowns
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

  // FieldSet: Zone changed (per row)
  void onFieldZoneChanged(int index, String? value) async {
    fieldSets[index].selectedZone.value = value ?? '';
    fieldSets[index].selectedLocation.value = ''; // Reset location

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

    fieldSets.refresh(); // Refresh UI
  }

  // FieldSet: Location changed
  void onFieldLocationChanged(int index, String? value) {
    fieldSets[index].selectedLocation.value = value ?? '';
  }

  // FieldSet: Planning status
  void onPlanningStatusChanged(int index, String? value) {
    fieldSets[index].planningStatus.value = value ?? 'Not Started';
  }

  // Text field handlers with auto-calculation
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

  // Add new field set
  void addFieldSet() {
    fieldSets.add(FieldSet());
  }

  // Refresh
  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    resetForm();
  }

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
        // Properly parse the list using your helper function
        List<GetAddPboqMsResponse> response = getAddPboqMsResponseFromJson(
          jsonEncode(list),
        );

        if (response[0].status == true) {
          log(response[0].status.toString());

          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: 'PBOQ Measurement Sheet added successfully!',
          );
          Get.offNamed(AppRoutes.pboqList);

          Get.offNamed(AppRoutes.pboqList);
        } else if (response[0].status == false) {
          // Use actual error or message from API
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to add measurement sheet.");

          AppSnackbarStyles.showError(title: 'Failed', message: errorMessage);
        }
      } else {
        AppSnackbarStyles.showError(title: 'Failed', message: "Failed");
        // AppSnackbarStyles.showError(
        //   title: 'Server Error',
        //   message: 'No response from server',
        // );
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
