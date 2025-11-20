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
  var fieldSets = <FieldSet>[].obs;

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
  RxBool isLoadingMore = false.obs;
  RxString errorMessage = ''.obs;
  RxMap<int, PlanningStatus> planningStatusData = <int, PlanningStatus>{}.obs;

  // Planning status options

  @override
  void onInit() {
    super.onInit();

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    log(
      'AddPboqFormController → Arguments received: $args',
      name: 'AddPboqForm',
    );

    if (args != null) {
      mesurmentCtrl.projectId.value = args["project_id"] ?? 0;
      mesurmentCtrl.packageId.value = args["package_id"] ?? 0;
      PBOQMSctr.pboqId.value = args["pboq_id"] ?? 0;
      uom.value = args["uom"] ?? "";

      log(
        'AddPboqFormController → Set values: projectId=${mesurmentCtrl.projectId.value}, packageId=${mesurmentCtrl.packageId.value}, pboqId=${PBOQMSctr.pboqId.value}',
        name: 'AddPboqForm',
      );
    } else {
      log(
        'AddPboqFormController → No arguments received!',
        name: 'AddPboqForm',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context != null) {
        // Auto-bind Package
        log(
          'AddPboqFormController → Fetching packages for projectId: ${mesurmentCtrl.projectId.value}',
          name: 'AddPboqForm',
        );
        await _pkgCtrl
            .fetchPackages(
              context: Get.context!,
              projectId: mesurmentCtrl.projectId.value,
            )
            .then((_) {
              log(
                'AddPboqFormController → Packages fetched: ${_pkgCtrl.packageNames}',
                name: 'AddPboqForm',
              );
              final String? autoPackageId = mesurmentCtrl.packageId.value
                  .toString();
              log(
                'AddPboqFormController → Looking for packageId: $autoPackageId',
                name: 'AddPboqForm',
              );
              if (autoPackageId != null &&
                  autoPackageId != 'null' &&
                  autoPackageId.isNotEmpty &&
                  autoPackageId != '0') {
                final String? packageName = _pkgCtrl.getPackageNameById(
                  autoPackageId,
                );
                log(
                  'AddPboqFormController → Found packageName: $packageName',
                  name: 'AddPboqForm',
                );
                if (packageName != null && packageName.isNotEmpty) {
                  selectedPackage.value = packageName;
                  log(
                    'AddPboqFormController → Auto-bound package: $packageName',
                    name: 'AddPboqForm',
                  );
                  onPackageChanged(packageName);
                } else {
                  log(
                    'AddPboqFormController → Package name not found for ID: $autoPackageId',
                    name: 'AddPboqForm',
                  );
                }
              } else {
                log(
                  'AddPboqFormController → Invalid packageId: $autoPackageId',
                  name: 'AddPboqForm',
                );
              }
            });

        // Fetch PBOQs
        log(
          'AddPboqFormController → Fetching PBOQs for projectId: ${mesurmentCtrl.projectId.value}, packageId: ${mesurmentCtrl.packageId.value}',
          name: 'AddPboqForm',
        );
        await _pboqCtrl.fetchPboqs(
          forceFetch: true,
          context: Get.context!,
          projectId: mesurmentCtrl.projectId.value,
          packageId: mesurmentCtrl.packageId.value,
        );
        log(
          'AddPboqFormController → PBOQs fetched: ${_pboqCtrl.pboqNames}',
          name: 'AddPboqForm',
        );

        // Initialize first field set with correct UOM
        if (fieldSets.isEmpty) {
          final initialFieldSet = FieldSet();
          initialFieldSet.uom.value = PBOQMSctr.uom.value.isNotEmpty
              ? PBOQMSctr.uom.value
              : 'Unit';
          fieldSets.add(initialFieldSet);
          log(
            'AddPboqFormController → Initialized first fieldSet with UOM: ${initialFieldSet.uom.value}',
            name: 'AddPboqForm',
          );
        }

        // Auto-bind PBOQ
        final String? autoPboqId = PBOQMSctr.pboqId.value.toString();
        log(
          'AddPboqFormController → Looking for pboqId: $autoPboqId',
          name: 'AddPboqForm',
        );
        if (autoPboqId != null &&
            autoPboqId != 'null' &&
            autoPboqId.isNotEmpty &&
            autoPboqId != '0') {
          final String? pboqName = _pboqCtrl.getPboqNameById(autoPboqId);
          log(
            'AddPboqFormController → Found pboqName: $pboqName',
            name: 'AddPboqForm',
          );
          if (pboqName != null && pboqName.isNotEmpty) {
            selectedPboqName.value = pboqName;
            log(
              'AddPboqFormController → Auto-bound PBOQ: $pboqName',
              name: 'AddPboqForm',
            );
            onPboqNameChanged(pboqName);
          } else {
            log(
              'AddPboqFormController → PBOQ name not found for ID: $autoPboqId',
              name: 'AddPboqForm',
            );
          }
        } else {
          log(
            'AddPboqFormController → Invalid pboqId: $autoPboqId',
            name: 'AddPboqForm',
          );
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
        fs.planningStatus.value = '';
        fs.uom.value = PBOQMSctr.uom.value.isNotEmpty
            ? PBOQMSctr.uom.value
            : uom.value;
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

    // Update UOM for all field sets
    for (final fs in fieldSets) {
      fs.uom.value = PBOQMSctr.uom.value.isNotEmpty
          ? PBOQMSctr.uom.value
          : 'Unit';
    }
  }

  // Zone changed per row
  void onFieldZoneChanged(int index, String? value) async {
    fieldSets[index].selectedZone.value = value ?? '';
    fieldSets[index].selectedLocation.value = '';
    fieldSets[index].planningStatus.value = '';

    final String? zoneId = _zoneCtrl.getZoneIdByName(value ?? '');
    final String? pkgId = _pkgCtrl.getPackageIdByName(selectedPackage.value);
    final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);

    if (zoneId == null || pkgId == null || pboqId == null) return;

    if (zoneId.isNotEmpty && zoneId.isNotEmpty && pboqId.isEmpty) {
      await _zoneLocationCtrl.fetchZoneLocations(
        context: Get.context!,
        forceFetch: true,
        projectId: mesurmentCtrl.projectId.value,
        packageId: int.tryParse(pkgId) ?? 0,
        pboqId: int.tryParse(pboqId) ?? 0,
        zoneId: int.tryParse(zoneId) ?? 0,
      );
    }

    // Fetch planning status for this zone
    await fetchPlanningStatusForZone(int.tryParse(zoneId) ?? 0, index);

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
    final newFieldSet = FieldSet();
    newFieldSet.uom.value = PBOQMSctr.uom.value.isNotEmpty
        ? PBOQMSctr.uom.value
        : 'Unit';
    fieldSets.add(newFieldSet);
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
      fs.planningStatus.value = '';
      fs.uom.value = PBOQMSctr.uom.value;
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
          if (Get.arguments == null) {
            Get.offNamed(AppRoutes.pboqList);
          } else {
            Navigator.pop(Get.context!);
          }
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
    // if (selectedPackage.isEmpty) {
    //   Get.snackbar('Error', 'Please select a package');
    //   return;
    // }
    // if (selectedPboqName.isEmpty) {
    //   Get.snackbar('Error', 'Please select a PBOQ');
    //   return;
    // }

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

  Future<void> fetchPlanningStatusForZone(int zoneId, int fieldIndex) async {
    try {
      final String? pboqId = _pboqCtrl.getPboqIdByName(selectedPboqName.value);
      if (pboqId == null) {
        log('PBOQ ID is null', name: 'AddPboqFormController');
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
        name: 'AddPboqFormController',
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

          // Update the field set's planning status
          final statusText =
              'Planned: ${planningData.plannedQty} | MS Qty: ${planningData.newMsQty}';
          fieldSets[fieldIndex].planningStatus.value = statusText;

          log(
            'Updated planning status: $statusText',
            name: 'AddPboqFormController',
          );

          // Force UI update
          fieldSets.refresh();
        } else {
          log(
            'API response status false or no data',
            name: 'AddPboqFormController',
          );
        }
      } else {
        log('Empty API response', name: 'AddPboqFormController');
      }
    } catch (e) {
      log('Error fetching planning status: $e', name: 'AddPboqFormController');
    }
  }

  // Reset
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
