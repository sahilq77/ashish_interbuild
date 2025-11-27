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

class AddAccIssueFormController extends GetxController {
  final RxString selectedPackage = ''.obs;

  final RxString selectedProject = ''.obs;
  // final RxList<String> packages = <String>[
  //   'BlueNile Cafe Package',
  //   'Alpha Package',
  // ].obs;
  final RxString accCategory = ''.obs;
  final RxList<String> accCategories = <String>['Amit', 'Ganesh', 'Sumit'].obs;

  final RxString priority = ''.obs;
  final RxList<String> priorities = <String>[
    'Critical',
    'High',
    'Medium',
    'Low',
  ].obs;
  final RxString category = ''.obs;
  final RxList<String> categories = <String>['Milestone', 'Milestone-1'].obs;

  final RxString keyDelayEvents = ''.obs;
  final RxList<String> keyDelayOptions = <String>['Yes', 'No'].obs;

  final RxString affectedMilestone = ''.obs;
  final RxList<String> milestones = <String>[
    'Milestone 1',
    'Milestone 2',
    'Milestone 3',
  ].obs;

  final RxString briefDetails = ''.obs;

  final Rx<DateTime> issueOpenDate = DateTime.now().obs;

  final RxString role = ''.obs;
  final RxList<String> roles = <String>['Doer 1', 'Doer 2', 'Doer 3'].obs;
  var attachmentFile = Rxn<PlatformFile>();
  final RxString attachmentFileName = 'No file chosen'.obs;

  final projectdController = Get.find<ProjectNameDropdownController>();
  final packageNameController = Get.find<PackageNameController>();
  final accCategoryController = Get.find<AccCategoryController>();
  final doerRoleController = Get.find<DoerRoleController>();
  final milestoneController = Get.find<MilestoneController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        // zoneController.fetchZones(context: Get.context!);
        projectdController.fetchProjects(context: Get.context!);
        accCategoryController.fetchAccCategories(context: Get.context!);
        doerRoleController.fetchDoerRoles(context: Get.context!);
        milestoneController.fetchMilestones(context: Get.context!);
      }
    });
  }

  void onAccCategoryChanged(String? value) {
    accCategory.value = value ?? '';
  }

  void onProjectChanged(String? value) async {
    selectedProject.value = value ?? "";
    final projectId = projectdController.getProjectIdByName(value ?? "");
    await packageNameController.fetchPackages(
      context: Get.context!,
      forceFetch: true,
      projectId: int.parse(projectId!),
    );
  }

  void onPackageChanged(String? value) {
    selectedPackage.value = value ?? '';
  }

  void onPriorityChanged(String? value) {
    priority.value = value ?? '';
  }

  void onKeyDelayEventsChanged(String? value) {
    keyDelayEvents.value = value ?? '';
  }

  void onAffectedMilestoneChanged(String? value) {
    affectedMilestone.value = value ?? '';
  }

  void onBriefDetailsChanged(String value) {
    briefDetails.value = value;
  }

  void onIssueOpenDateChanged(DateTime date) {
    issueOpenDate.value = date;
  }

  void onRoleChanged(String? value) {
    role.value = value ?? '';
  }

  Future<void> pickAttachment() async {
    await pickFile('attachment', allowMultiple: false);
  }

  void submitForm() {
    if (accCategory.value.isEmpty ||
        affectedMilestone.value.isEmpty ||
        briefDetails.value.isEmpty ||
        issueOpenDate.value == null ||
        role.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }
    print('ACC Category: $accCategory');
    print('Priority: $priority');
    print('Key Delay Events: $keyDelayEvents');
    print('Affected Milestone: $affectedMilestone');
    print('Brief Details: $briefDetails');
    print('Issue Open Date: $issueOpenDate');
    print('Role: $role');
    print('Attachment: $attachmentFileName');
    Get.snackbar('Success', 'Form Submitted');
  }

  Future<void> onRefresh() async {
    accCategory.value = '';
    priority.value = '';
    keyDelayEvents.value = '';
    affectedMilestone.value = '';
    briefDetails.value = '';
    issueOpenDate.value = DateTime.now();
    role.value = '';
    attachmentFileName.value = 'No file chosen';
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

  Future<void> pickFile(String field, {bool allowMultiple = true}) async {
    try {
      log('Picking file for field: $field, allowMultiple: $allowMultiple');
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
        attachmentFile.value = result.files.first;
        attachmentFileName.value = result.files.first.name;
        update();
      } else {
        log('No file selected for field: $field');
      }
    } catch (e, stackTrace) {
      log('Error picking file for $field: $e', stackTrace: stackTrace);
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
