import 'dart:convert';
import 'dart:developer';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:ashishinterbuild/app/data/models/acc/get_update_submit_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart'
    show AccController;
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart' show AppUtility;
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/network/networkcall.dart';

class UpdateAccFormController extends GetxController {
  final AccController listController = Get.put(AccController());
  RxBool isLoading = false.obs;
  final RxString priority = ''.obs;
  var attachmentFile = Rxn<PlatformFile>();
  final RxList<String> priorities = <String>[
    'Low',
    'Medium',
    'High',
    'Critical',
  ].obs;
  RxBool issueStatus = false.obs;
  final RxString role = ''.obs;

  final Rx<DateTime> issueOpenSinceDate = DateTime.now().obs;
  final Rx<DateTime> issueCloseDate = DateTime.now().obs;

  final RxString attachmentFileName = 'No file chosen'.obs;

  final remark = TextEditingController();

  final doerRoleController = Get.find<DoerRoleController>();
  RxString accID = ''.obs;
  RxString projectID = ''.obs;
  final RxString attchmentLink = ''.obs;

  RxBool isLoadingArg = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context != null) {
        await doerRoleController.fetchDoerRoles(context: Get.context!);
        await _bindFormData();
      }
    });
  }

  Future<void> _bindFormData() async {
    final args = Get.arguments as Map<String, dynamic>?;
    isLoadingArg.value = true;
    // Log the raw arguments first
    if (args == null) {
      developer.log(
        '🔴 _bindFormData: No arguments passed (Get.arguments is null)',
      );
      return;
    }

    developer.log('''
🟢 _bindFormData called with arguments:
${args.entries.map((e) => '   • ${e.key}: ${e.value}').join('\n')}
  ''');

    try {
      // 1. Project Binding

      accID.value = args["acc_id"] ?? "";
      projectID.value = args["project_id"] ?? "";
      attchmentLink.value = args['attachment'] ?? "";
      developer.log('📂 ACC Card → ID: ${accID.value}');

      // 3. Priority
      final priorityValue = args['priority']?.toString() ?? '';
      priority.value = priorityValue;
      developer.log('🔥 Priority → "$priorityValue"');
      final issueStatuss = args['issue_status']?.toString() ?? '';
      if (issueStatuss == "1") {
        issueStatus.value = true;
      }

      // 6. Role (Doer Role)
      if (args['role'] != null) {
        final roleId = args['role'].toString();
        final roleName = doerRoleController.getDoerRoleNameById(roleId);
        developer.log('👤 Binding Role → ID: $roleId, Name: $roleName');
        if (roleName != null) {
          role.value = roleName;
          developer.log('✅ Role set to: $roleName');
        }
      }

      // 7. Brief Details
      final brief = args['remark']?.toString() ?? '';
      remark.text = brief;
      developer.log('📝 Brief Details → "${brief.replaceAll('\n', '\\n')}"');

      // 8. Issue Open Date
      if (args['issue_open_date'] != null) {
        final dateStr = args['issue_open_date'].toString().trim();
        try {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);

            final parsedDate = DateTime(year, month, day);
            issueOpenSinceDate.value = parsedDate;
            developer.log(
              'Issue Open Date → $parsedDate (parsed from DD-MM-YYYY)',
            );
          } else {
            throw FormatException('Invalid date format');
          }
        } catch (e) {
          developer.log(
            'Failed to parse issue_open_date: "$dateStr" → using current date',
            error: e,
          );
          issueOpenSinceDate.value = DateTime.now();
        }
      }

      // Final summary
      developer.log(
        '🎉 _bindFormData completed successfully! Form pre-filled.',
      );
    } catch (e, stackTrace) {
      developer.log(
        '💥 Error in _bindFormData',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      isLoadingArg.value = false;
    }
  }

  void onPriorityChanged(String? value) {
    priority.value = value ?? '';
  }

  void onRoleChanged(String? value) {
    role.value = value ?? '';
  }

  void onIssueOpenSinceDateChanged(DateTime date) {
    issueOpenSinceDate.value = date;
  }

  void onIssueCloseDateChanged(DateTime date) {
    issueCloseDate.value = date;
  }

  void issueStatusChanged(bool? value) {
    issueStatus.value = value ?? false;
  }

  Future<void> pickAttachment() async {
    await pickFile('attachment', allowMultiple: false);
  }

  void onRemarkChanged(String value) {
    remark.text = value;
  }

  Future<void> onRefresh() async {
    // priority.value = 'Low';
    // role.value = '';
    // issueOpenSinceDate.value = DateTime.now();

    // attachmentFileName.value = 'No file chosen';
    // remark.text = '';
    // await doerRoleController.fetchDoerRoles(
    //   context: Get.context!,
    //   forceFetch: true,
    // );
    await _bindFormData();
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

  Future<void> submitForm(BuildContext context) async {
    isLoading.value = true;
    try {
      final String doerId =
          doerRoleController.getDoerRoleIdByName(role.value) ?? "";

      final Map<String, String> formData = {
        'acc_id': accID.value,
        'project_id': projectID.value,
        'priority': priority.value,
        'doers': doerId,
        'open_since': issueOpenSinceDate.value
            .toIso8601String()
            .split('T')
            .first,
        'close_date_status': issueStatus.value ? '1' : '0',
        if (remark.text.trim().isNotEmpty) 'remark': remark.text.trim(),
      };

      final Map<String, File> fileMap = {};
      if (attachmentFile.value != null && attachmentFile.value!.path != null) {
        final file = File(attachmentFile.value!.path!);
        if (await file.exists()) {
          fileMap['attachment_file'] = file;
        }
      }

      List<Object?>? list = await Networkcall().postFormDataMethod(
        Networkutility.updateAccApi,
        Networkutility.updateAcc,
        formData,
        fileMap,
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetUpdateSubmitResponse> response =
            getUpdateSubmitResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: response[0].message ?? 'ACC updated successfully',
          );
          Navigator.pop(context);
          listController.fetchWFUList(context: Get.context!, reset: true);
        } else {
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to update ACC.");
          AppSnackbarStyles.showError(title: 'Failed', message: errorMessage);
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Failed',
          message: "No response from server",
        );
      }
    } catch (e, stack) {
      log('Submit Error: $e', stackTrace: stack);
      AppSnackbarStyles.showError(
        title: "Error",
        message: "Something went wrong. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
