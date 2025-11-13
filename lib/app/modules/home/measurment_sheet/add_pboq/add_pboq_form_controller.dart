import 'dart:developer';

import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
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
  var fieldSets = <FieldSet>[FieldSet()].obs;

  // Injected real controller
  final MeasurementSheetController mesurmentCtrl = Get.find();
  late final PackageNameController _pkgCtrl = Get.find<PackageNameController>();
  late final PboqNameController _pboqCtrl = Get.find<PboqNameController>();
  late final ZoneController _zoneCtrl = Get.find<ZoneController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        _pkgCtrl.fetchPackages(
          context: Get.context!,
          projectId: mesurmentCtrl.projectId.value,
        );
      }
    });
  }

  // Dynamic package names from API
  List<String> get packageNames => _pkgCtrl.packageNames;
  List<String> get pboqNames => _pboqCtrl.pboqNames;
  List<String> get zoneNames => _zoneCtrl.zoneNames;

  final List<String> locations = ['Location A', 'Location B', 'Location C'];

  void onPackageChanged(String? newPackageName) async {
    selectedPackage.value = newPackageName ?? '';

    // ---- LOG THE NAME ------------------------------------------------
    log('Selected Package Name: $newPackageName');

    // ---- LOG THE ID --------------------------------------------------
    final String? pkgId = _pkgCtrl.getPackageIdByName(
      newPackageName.toString(),
    );
    await _pboqCtrl.fetchPboqs(
      forceFetch: true,
      context: Get.context!,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.parse(pkgId.toString()),
    );
    log('Selected Package ID  : $pkgId');
  }

  void onPboqNameChanged(String? value) async {
    selectedPboqName.value = value ?? '';

    // ---- LOG THE NAME ------------------------------------------------
    log('Selected PBOQ Name: $value');

    // ---- LOG THE ID --------------------------------------------------
    final String? PBOQId = _pboqCtrl.getPboqIdByName(value.toString());
    log('Selected PBOQ ID  : $PBOQId');

    // ---- FETCH ZONES WITH PACKAGE ID & PBOQ ID -----------------------
    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);
   
    await _zoneCtrl.fetchZones(
      forceFetch: true,
      context: Get.context!,
      projectId: mesurmentCtrl.projectId.value,
      packageId: int.tryParse(pkgId ?? '') ?? 0,
      pboqId: int.tryParse(PBOQId ?? '') ?? 0,
    );
  }

  void onZoneChanged(String? value) {
    selectedZoneName.value = value ?? '';

    // ---- LOG THE NAME ------------------------------------------------
    log('Selected Zone Name: $value');

    // ---- LOG THE ID --------------------------------------------------
    final String? zoneId = _zoneCtrl.getZoneIdByName(value.toString());
    log('Selected Zone ID  : $zoneId');
  }

  void onLocationChanged(int index, String? value) {
    if (value != null) fieldSets[index].selectedLocation.value = value;
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
