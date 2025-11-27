import 'dart:developer';
import 'dart:io';

import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateAccFormController extends GetxController {
  final RxString priority = 'Low'.obs;
  var attachmentFile = Rxn<PlatformFile>();
  final RxList<String> priorities = <String>[
    'Low',
    'Medium',
    'High',
    'Critical',
  ].obs;
RxBool issueStatus = false.obs;
  final RxString role = ''.obs;


  final Rx<DateTime> issueOpenSinceDate = DateTime(2025, 10, 19).obs;
  final Rx<DateTime> issueCloseDate = DateTime.now().obs;

  final RxString attachmentFileName = 'No file chosen'.obs;

  final RxString remark = ''.obs;
  final doerRoleController = Get.find<DoerRoleController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        // zoneController.fetchZones(context: Get.context!);

        doerRoleController.fetchDoerRoles(context: Get.context!);
      }
    });
  }

  void onPriorityChanged(String? value) {
    priority.value = value ?? 'Low';
  }

  void onRoleChanged(String? value) {
    role.value = value ?? 'Production PMS PC';
  }

  void onIssueOpenSinceDateChanged(DateTime date) {
    issueOpenSinceDate.value = date;
  }

  void onIssueCloseDateChanged(DateTime date) {
    issueCloseDate.value = date;
  }
 void issueStatusChanged(bool? value) {
    issueStatus.value = value ??false;
  }
  Future<void> pickAttachment() async {
    await pickFile('attachment', allowMultiple: false);
  }

  void onRemarkChanged(String value) {
    remark.value = value;
  }

  void submitForm() {
    if (priority.value.isEmpty || role.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }
    print('Priority: $priority');
    print('Role: $role');
    print('Issue Open Since Date: $issueOpenSinceDate');
    print('Issue Close Date: $issueCloseDate');
    print('Attachment: $attachmentFileName');
    print('Remark: $remark');
    Get.snackbar('Success', 'Form Updated');
  }

  Future<void> onRefresh() async {
    priority.value = 'Low';
    role.value = 'Production PMS PC';
    issueOpenSinceDate.value = DateTime(2025, 10, 19);
    issueCloseDate.value = DateTime.now();
    attachmentFileName.value = 'No file chosen';
    remark.value = '';
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
