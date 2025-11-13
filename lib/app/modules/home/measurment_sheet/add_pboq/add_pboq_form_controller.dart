import 'dart:developer';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FieldSet {
  var selectedZone = ''.obs;
  var planningStatus = 'Not Started'.obs;
  var selectedLocation = ''.obs;
  var subLocation = ''.obs;
  var uom = 'Unit'.obs;
  var nos = ''.obs;
  var length = ''.obs;
  var height = ''.obs;
  var remark = ''.obs;
  FieldSet();
}

class AddPboqFormController extends GetxController {
  var selectedPackage = ''.obs;
  var selectedPboqName = ''.obs;
  var selectedZoneName = ''.obs;
  var selectedZoneLocationName = ''.obs;
  var fieldSets = <FieldSet>[FieldSet()].obs;

  // Injected real controller
  final MeasurementSheetController mesurmentCtrl = Get.find();
  late final PackageNameController _pkgCtrl = Get.find<PackageNameController>();
  late final PboqNameController _pboqCtrl = Get.find<PboqNameController>();
  late final ZoneController _zoneCtrl = Get.find<ZoneController>();
  late final ZoneLocationController _zoneLocationCtrl =
      Get.find<ZoneLocationController>();
  //  mesurmentCtrl.packageId;
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        _pkgCtrl
            .fetchPackages(
              context: Get.context!,
              projectId: mesurmentCtrl.projectId.value,
            )
            .then((_) {
              // Auto-bind package using mesurmentCtrl.packageId
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
                  // Trigger dependent loading
                  onPackageChanged(packageName);
                }
              }
            });
      }
    });
  }

  // Dynamic package names from API
  List<String> get packageNames => _pkgCtrl.packageNames;
  List<String> get pboqNames => _pboqCtrl.pboqNames;
  List<String> get zoneNames => _zoneCtrl.zoneNames;
  List<String> get zoneLocations => _zoneLocationCtrl.zoneLocationNames;

  // === NEW: Reset helper for dependent dropdowns ===
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
      selectedZoneName.value = '';
      _zoneCtrl.zoneNames.clear();
    }
    if (resetLocation) {
      selectedZoneLocationName.value = '';
      _zoneLocationCtrl.zoneLocationNames.clear();
    }
    if (resetFieldSets) {
      for (final fs in fieldSets) {
        fs.selectedZone.value = '';
        fs.selectedLocation.value = '';
        fs.subLocation.value = '';
        fs.nos.value = '';
        fs.length.value = '';
        fs.height.value = '';
        fs.remark.value = '';
        fs.planningStatus.value = 'Not Started';
        fs.uom.value = 'Unit';
      }
    }
  }

  void onPackageChanged(String? newPackageName) async {
    selectedPackage.value = newPackageName ?? '';

    // Reset all dependent fields
    _resetDependents(
      resetPboq: true,
      resetZone: true,
      resetLocation: true,
      resetFieldSets: true,
    );

    log('Selected Package Name: $newPackageName');
    final String? pkgId = _pkgCtrl.getPackageIdByName(
      newPackageName.toString(),
    );
    await _pboqCtrl.fetchPboqs(
      forceFetch: true,
      context: Get.context!,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.parse(pkgId.toString()),
    );
    log('Selected Package ID : $pkgId');
  }

  void onPboqNameChanged(String? value) async {
    selectedPboqName.value = value ?? '';

    // Reset dependent fields below PBOQ
    _resetDependents(
      resetZone: true,
      resetLocation: true,
      resetFieldSets: true,
    );

    log('Selected PBOQ Name: $value');
    final String? PBOQId = _pboqCtrl.getPboqIdByName(value.toString());
    log('Selected PBOQ ID : $PBOQId');

    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);
    await _zoneCtrl.fetchZones(
      forceFetch: true,
      context: Get.context!,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.tryParse(pkgId ?? '') ?? 0,
      pboqId: int.tryParse(PBOQId ?? '') ?? 0,
    );
  }

  void onZoneChanged(String? value) async {
    selectedZoneName.value = value ?? '';

    // Reset dependent fields below Zone
    _resetDependents(resetLocation: true, resetFieldSets: true);

    // === ADD THIS LINE TO CLEAR GLOBAL LOCATION DROPDOWN ===
    selectedZoneLocationName.value = '';

    log('Selected Zone Name: $value');
    final String? zoneId = _zoneCtrl.getZoneIdByName(value.toString());
    log('Selected Zone ID : $zoneId');

    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);
    final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);
    if (pkgId == null || pboqId == null || zoneId == null) {
      log('Warning: Missing required IDs – cannot fetch zone locations');
      return;
    }
    await _zoneLocationCtrl.fetchZoneLocations(
      context: Get.context!,
      forceFetch: true,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.tryParse(pkgId) ?? 0,
      pboqId: int.tryParse(pboqId) ?? 0,
      zoneId: int.tryParse(zoneId) ?? 0,
    );

    // Clear previously selected locations in field sets
    for (final fs in fieldSets) {
      fs.selectedLocation.value = '';
    }
  }

  void onLocationChanged(String? value) {
    selectedZoneLocationName.value = value ?? '';

    // Reset only field set values (keep hierarchy above)
    _resetDependents(resetFieldSets: true);

    log('Selected Zone Location Name: $value');
    final String? zoneLocationId = _zoneLocationCtrl.getZoneLocationIdByName(
      value.toString(),
    );
    log('Selected Location ID : $zoneLocationId');
  }

  void onSubLocationChanged(int index, String value) {
    fieldSets[index].subLocation.value = value;
  }

  void onNosChanged(int index, String value) {
    fieldSets[index].nos.value = value;
  }

  void onLengthChanged(int index, String value) {
    fieldSets[index].length.value = value;
  }

  void onHeightChanged(int index, String value) {
    fieldSets[index].height.value = value;
  }

  void onRemarkChanged(int index, String value) {
    fieldSets[index].remark.value = value;
  }

  void addFieldSet() {
    fieldSets.add(FieldSet());
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    resetForm();
  }

  void submitForm() {
    if (selectedPackage.isEmpty) {
      Get.snackbar('Error', 'Please select a package name');
      return;
    }
    if (selectedPboqName.isEmpty) {
      Get.snackbar('Error', 'Please select a PBOQ name');
      return;
    }
    for (int i = 0; i < fieldSets.length; i++) {
      final f = fieldSets[i];
      if (f.selectedZone.isEmpty) {
        Get.snackbar('Error', 'Please select a zone for field set ${i + 1}');
        return;
      }
      if (f.selectedLocation.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a location for field set ${i + 1}',
        );
        return;
      }
    }
    print('=== SUBMIT ===');
    print('Package: ${selectedPackage.value}');
    print('PBOQ: ${selectedPboqName.value}');
    for (int i = 0; i < fieldSets.length; i++) {
      final f = fieldSets[i];
      print('--- Set ${i + 1} ---');
      print('Zone: ${f.selectedZone.value}');
      print('Planning: ${f.planningStatus.value}');
      print('Location: ${f.selectedLocation.value}');
      print('Sub-Loc: ${f.subLocation.value}');
      print('UOM: ${f.uom.value}');
      print('Nos: ${f.nos.value}');
      print('Length: ${f.length.value}');
      print('Height: ${f.height.value}');
      print('Remark: ${f.remark.value}');
    }
    resetForm();
    Get.snackbar('Success', 'Form submitted successfully');
  }

  void resetForm() {
    selectedPackage.value = '';
    selectedPboqName.value = '';

    fieldSets.clear();
    fieldSets.add(FieldSet());
  }
}
