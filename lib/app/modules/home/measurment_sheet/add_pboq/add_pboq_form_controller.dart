import 'dart:developer';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  FieldSet();
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

  // Text field handlers
  void onSubLocationChanged(int index, String value) =>
      fieldSets[index].subLocation.value = value;
  void onNosChanged(int index, String value) =>
      fieldSets[index].nos.value = value;
  void onLengthChanged(int index, String value) =>
      fieldSets[index].length.value = value;
  void onBreadthChanged(int index, String value) =>
      fieldSets[index].breadth.value = value;
  void onHeightChanged(int index, String value) =>
      fieldSets[index].height.value = value;
  void onRemarkChanged(int index, String value) =>
      fieldSets[index].remark.value = value;

  // Add new field set
  void addFieldSet() {
    fieldSets.add(FieldSet());
  }

  // Refresh
  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    resetForm();
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

    print('=== SUBMIT ===');
    print('Package: ${selectedPackage.value}');
    print('PBOQ: ${selectedPboqName.value}');
    for (int i = 0; i < fieldSets.length; i++) {
      final f = fieldSets[i];
      print('--- Row ${i + 1} ---');
      print('Zone: ${f.selectedZone.value}');
      print('Location: ${f.selectedLocation.value}');
      print('Planning:: ${f.planningStatus.value}');
      print('Sub-Loc: ${f.subLocation.value}');
      print('UOM: ${f.uom.value}');
      print('Nos: ${f.nos.value}');
      print('Length: ${f.length.value}');
      print('Breadth: ${f.breadth.value}');
      print('Height: ${f.height.value}');
      print('Remark: ${f.remark.value}');
    }

    Get.snackbar('Success', 'Submitted successfully');
    resetForm();
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
