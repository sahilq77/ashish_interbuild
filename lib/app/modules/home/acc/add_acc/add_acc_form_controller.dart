import 'dart:developer';
import 'dart:io';

import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_controller.dart'
    show MilestoneController;
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/app_colors.dart';

class AccFieldSet {
  var selectedProject = ''.obs;
  var selectedPackage = ''.obs;
  var accCategory = ''.obs;
  var priority = ''.obs;
  var keyDelayEvents = ''.obs;
  var affectedMilestone = ''.obs;
  var briefDetails = ''.obs;
  var issueOpenDate = DateTime.now().obs;
  var role = ''.obs;
  var attachmentFile = Rxn<PlatformFile>();
  var attachmentFileName = 'No file chosen'.obs;
}

class AddAccIssueFormController extends GetxController {
  final RxList<String> priorities = <String>[
    'Critical',
    'High',
    'Medium',
    'Low',
  ].obs;
  final RxList<String> keyDelayOptions = <String>['Yes', 'No'].obs;
  
  // Dynamic field sets
  var fieldSets = <AccFieldSet>[].obs;

  final projectdController = Get.find<ProjectNameDropdownController>();
  final packageNameController = Get.find<PackageNameController>();
  final accCategoryController = Get.find<AccCategoryController>();
  final doerRoleController = Get.find<DoerRoleController>();
  final milestoneController = Get.find<MilestoneController>();

  @override
  void onInit() {
    super.onInit();
    // Initialize first field set
    fieldSets.add(AccFieldSet());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        projectdController.fetchProjects(context: Get.context!);
        accCategoryController.fetchAccCategories(context: Get.context!);
        doerRoleController.fetchDoerRoles(context: Get.context!);
        milestoneController.fetchMilestones(context: Get.context!);
      }
    });
  }

  void onAccCategoryChanged(int index, String? value) {
    fieldSets[index].accCategory.value = value ?? '';
  }

  void onProjectChanged(int index, String? value) async {
    fieldSets[index].selectedProject.value = value ?? "";
    fieldSets[index].selectedPackage.value = '';
    final projectId = projectdController.getProjectIdByName(value ?? "");
    if (projectId != null) {
      await packageNameController.fetchPackages(
        context: Get.context!,
        forceFetch: true,
        projectId: int.parse(projectId),
      );
    }
  }

  void onPackageChanged(int index, String? value) {
    fieldSets[index].selectedPackage.value = value ?? '';
  }

  void onPriorityChanged(int index, String? value) {
    fieldSets[index].priority.value = value ?? '';
  }

  void onKeyDelayEventsChanged(int index, String? value) {
    fieldSets[index].keyDelayEvents.value = value ?? '';
  }

  void onAffectedMilestoneChanged(int index, String? value) {
    fieldSets[index].affectedMilestone.value = value ?? '';
  }

  void onBriefDetailsChanged(int index, String value) {
    fieldSets[index].briefDetails.value = value;
  }

  void onIssueOpenDateChanged(int index, DateTime date) {
    fieldSets[index].issueOpenDate.value = date;
  }

  void onRoleChanged(int index, String? value) {
    fieldSets[index].role.value = value ?? '';
  }

  Future<void> pickAttachment(int index) async {
    await pickFile(index, allowMultiple: false);
  }
  
  // Add new row
  void addFieldSet() {
    fieldSets.add(AccFieldSet());
  }
  
  // Remove row
  void removeFieldSet(int index) {
    if (fieldSets.length > 1) {
      fieldSets.removeAt(index);
    } else {
      // Clear first row instead of deleting
      final fs = fieldSets[0];
      fs.selectedProject.value = '';
      fs.selectedPackage.value = '';
      fs.accCategory.value = '';
      fs.priority.value = '';
      fs.keyDelayEvents.value = '';
      fs.affectedMilestone.value = '';
      fs.briefDetails.value = '';
      fs.issueOpenDate.value = DateTime.now();
      fs.role.value = '';
      fs.attachmentFile.value = null;
      fs.attachmentFileName.value = 'No file chosen';
    }
  }

  void submitForm() {
    for (int i = 0; i < fieldSets.length; i++) {
      final fs = fieldSets[i];
      if (fs.accCategory.value.isEmpty ||
          fs.affectedMilestone.value.isEmpty ||
          fs.briefDetails.value.isEmpty ||
          fs.role.value.isEmpty) {
        Get.snackbar('Error', 'Please fill all required fields for row ${i + 1}');
        return;
      }
    }
    
    for (int i = 0; i < fieldSets.length; i++) {
      final fs = fieldSets[i];
      print('Row ${i + 1}:');
      print('ACC Category: ${fs.accCategory.value}');
      print('Priority: ${fs.priority.value}');
      print('Key Delay Events: ${fs.keyDelayEvents.value}');
      print('Affected Milestone: ${fs.affectedMilestone.value}');
      print('Brief Details: ${fs.briefDetails.value}');
      print('Issue Open Date: ${fs.issueOpenDate.value}');
      print('Role: ${fs.role.value}');
      print('Attachment: ${fs.attachmentFileName.value}');
    }
    Get.snackbar('Success', 'Form Submitted');
  }

  Future<void> onRefresh() async {
    fieldSets.clear();
    fieldSets.add(AccFieldSet());
  }

  Future<bool> _requestStoragePermission() async {
    log('Checking storage permissions');
    bool granted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;
      log('Android SDK version: $sdkVersion');

      if (sdkVersion >= 33) {
        var status = await Permission.photos.status;
        if (!status.isGranted) {
          log('Requesting photos permission');
          status = await Permission.photos.request();
        }
        granted = status.isGranted;
        log('Photos permission ${granted ? "granted" : "denied"}');

        if (!granted) {
          status = await Permission.manageExternalStorage.status;
          if (!status.isGranted) {
            log('Requesting MANAGE_EXTERNAL_STORAGE permission');
            granted = await Permission.manageExternalStorage
                .request()
                .isGranted;
            if (!granted) {
              log('MANAGE_EXTERNAL_STORAGE denied, prompting system settings');
              Get.snackbar(
                'Permission Required',
                'Please enable "All Files Access" in system settings to pick files.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.redColor,
                colorText: Colors.white,
                mainButton: TextButton(
                  onPressed: () {
                    log('Opening system settings for MANAGE_EXTERNAL_STORAGE');
                    openAppSettings();
                  },
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else {
              log('MANAGE_EXTERNAL_STORAGE granted');
              granted = true;
            }
          } else {
            log('MANAGE_EXTERNAL_STORAGE already granted');
            granted = true;
          }
        }
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          log('Requesting storage permission');
          status = await Permission.storage.request();
        }
        granted = status.isGranted;
        log('Storage permission ${granted ? "granted" : "denied"}');
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        log('Requesting photos permission');
        status = await Permission.photos.request();
      }
      granted = status.isGranted;
      log('Photos permission ${granted ? "granted" : "denied"}');
    }

    if (!granted) {
      log('All permissions denied');
      Get.snackbar(
        'Permission Denied',
        'Storage access is required to pick files.',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return granted;
  }

  Future<void> pickFile(int index, {bool allowMultiple = true}) async {
    try {
      log('Picking file for row: $index, allowMultiple: $allowMultiple');
      if (!await _requestStoragePermission()) {
        log('File picking aborted due to permission denial');
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        log('Files picked: ${result.files.map((f) => f.name).toList()}');
        fieldSets[index].attachmentFile.value = result.files.first;
        fieldSets[index].attachmentFileName.value = result.files.first.name;
        update();
      } else {
        log('No file selected for row: $index');
      }
    } catch (e, stackTrace) {
      log('Error picking file for row $index: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
