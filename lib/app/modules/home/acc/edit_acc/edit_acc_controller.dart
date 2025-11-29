import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ashishinterbuild/app/data/models/acc/get_update_submit_response.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer; // Add this at the top if using log()

class EditAccController extends GetxController {
  final RxString selectedPackage = ''.obs;
  RxBool isLoading = false.obs;
  final RxString selectedProject = ''.obs;
  // final RxList<String> packages = <String>[
  //   'BlueNile Cafe Package',
  //   'Alpha Package',
  // ].obs;
  final RxString accCategory = ''.obs;
  final RxList<String> accCategories = <String>['Amit', 'Ganesh', 'Sumit'].obs;
  final AccController listController = Get.put(AccController());
  final RxString priority = ''.obs;
  final RxList<String> priorities = <String>[
    'Critical',
    'High',
    'Medium',
    'Low',
  ].obs;
  final RxString category = ''.obs;

  final RxString keyDelayEvents = ''.obs;
  final RxList<String> keyDelayOptions = <String>['Yes', 'No'].obs;

  final RxString affectedMilestone = ''.obs;

  final briefDetails = TextEditingController();

  final Rx<DateTime> issueOpenDate = DateTime.now().obs;

  final RxString role = ''.obs;
  final RxString accId = ''.obs;
  final RxString attchmentLink = ''.obs;

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
        projectdController.fetchProjects(context: Get.context!);
        accCategoryController.fetchAccCategories(context: Get.context!);
        doerRoleController.fetchDoerRoles(context: Get.context!);
        milestoneController.fetchMilestones(context: Get.context!);
        _bindFormData();
      }
    });
  }

  void _bindFormData() async {
    final args = Get.arguments as Map<String, dynamic>?;

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

      accId.value = args['acc_id'].toString();
      attchmentLink.value = args['attachment'].toString();
      developer.log('📂 ACC Card → ID: $accId');
      if (args['project_id'] != null) {
        final projectId = args['project_id'].toString();
        final projectName = projectdController.getProjectNameById(projectId);

        developer.log(
          '📂 Binding Project → ID: $projectId, Name: $projectName',
        );

        if (projectName != null) {
          selectedProject.value = projectName;
          developer.log('✅ Selected Project set to: $projectName');

          // Fetch packages
          await packageNameController.fetchPackages(
            context: Get.context!,
            forceFetch: true,
            projectId: int.parse(projectId),
          );
          developer.log('📦 Packages fetched for project ID: $projectId');

          // Bind package if provided
          if (args['package_id'] != null) {
            final packageId = args['package_id'].toString();
            final packageName = packageNameController.getPackageNameById(
              packageId,
            );
            developer.log(
              '📦 Binding Package → ID: $packageId, Name: $packageName',
            );

            if (packageName != null) {
              selectedPackage.value = packageName;
              developer.log('✅ Selected Package set to: $packageName');
            } else {
              developer.log('⚠️ Package name not found for ID: $packageId');
            }
          }
        } else {
          developer.log('⚠️ Project name not found for ID: $projectId');
        }
      }

      // 2. ACC Category
      if (args['acc_category'] != null) {
        final catId = args['acc_category'].toString();
        final categoryName = accCategoryController.getAccCategoryNameById(
          catId,
        );
        developer.log(
          '🏷️ Binding ACC Category → ID: $catId, Name: $categoryName',
        );
        if (categoryName != null) {
          accCategory.value = categoryName;
          developer.log('✅ ACC Category set to: $categoryName');
        }
      }

      // 3. Priority
      final priorityValue = args['priority']?.toString() ?? '';
      priority.value = priorityValue;
      developer.log('🔥 Priority → "$priorityValue"');

      // 4. Key Delay Events
      final keyDelay = args['key_delay_events']?.toString() ?? '';
      keyDelayEvents.value = keyDelay;
      developer.log('⏰ Key Delay Events → "$keyDelay"');

      // 5. Affected Milestone
      if (args['milestone_id'] != null) {
        final milestoneId = args['milestone_id'].toString();
        final milestoneName = milestoneController.getMilestoneNameById(
          milestoneId,
        );
        developer.log(
          '🎯 Binding Milestone → ID: $milestoneId, Name: $milestoneName',
        );
        if (milestoneName != null) {
          affectedMilestone.value = milestoneName;
          developer.log('✅ Affected Milestone set to: $milestoneName');
        }
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
      final brief = args['brief_detail']?.toString() ?? '';
      briefDetails.text = brief;
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
            issueOpenDate.value = parsedDate;
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
          issueOpenDate.value = DateTime.now();
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
    }
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
    briefDetails.text = value;
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

  void submitForm(BuildContext context) async {
    // Validate all field sets
    print("object");
    isLoading.value = true;

    try {
      // Prepare form data and files
      var formData = <String, String>{};
      var fileMap = <String, File>{};

      final projectId = projectdController.getProjectIdByName(
        selectedProject.value,
      );
      final packageId = packageNameController.getPackageIdByName(
        selectedPackage.value,
      );
      final categoryId = accCategoryController.getAccCategoryIdByName(
        accCategory.value,
      );
      final milestoneId = milestoneController.getMilestoneIdByName(
        affectedMilestone.value,
      );
      final doerId = doerRoleController.getDoerRoleIdByName(role.value);
      // Map fields to API keys

      formData['acc_data[0][acc_id]'] = accId.value;
      formData['acc_data[0][project_id]'] = projectId ?? "";
      formData['acc_data[0][acc_packages]'] = packageId ?? "";

      formData['acc_data[0][acc_categories]'] = categoryId ?? "";
      formData['acc_data[0][priority]'] = priority.value;
      formData['acc_data[0][details]'] = briefDetails.text
          .toString()
          .trim(); // Main description
      formData['acc_data[0][event_details]'] =
          keyDelayEvents.value; // Optional: better key
      // OR if backend strictly wants "event_details" for Yes/No too:
      // formData['acc_data[$i][event_details]'] = fs.keyDelayEvents.value; // override if needed

      formData['acc_data[0][milestones]'] = milestoneId ?? "";
      formData['acc_data[0][doers]'] = doerId ?? "";
      formData['acc_data[0][open_since]'] = issueOpenDate.value
          .toIso8601String()
          .split('T')
          .first;

      // Add attachment if exists
      // if (attachmentFile.value != null && attachmentFile.value!.path != null) {
      //   final file = File(attachmentFile.value!.path!);
      //   if (await file.exists()) {
      //     fileMap['attachment_file[0]'] = file;
      //   }
      // }

      // Call API
      List<Object?>? responseList = await Networkcall().postFormDataMethod(
        Networkutility.addAccApi,
        Networkutility.addAcc,
        formData,
        fileMap, // Send null if no files
        Get.context!,
      );

      if (responseList != null && responseList.isNotEmpty) {
        List<GetUpdateSubmitResponse> response =
            getUpdateSubmitResponseFromJson(jsonEncode(responseList));

        if (response[0].status == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: response[0].message ?? 'ACC added successfully!',
          );
          Navigator.pop(context);
          listController.fetchWFUList(context: Get.context!, reset: true);
        } else {
          AppSnackbarStyles.showError(
            title: 'Failed',
            message: response[0].error?.isNotEmpty == true
                ? response[0].error!
                : response[0].message ?? "Failed to submit",
          );
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'No Response',
          message: 'Server did not respond',
        );
      }
    } catch (e, stack) {
      log('Submit Error: $e', stackTrace: stack);
      AppSnackbarStyles.showError(
        title: "Error",
        message: "Failed to submit. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    accCategory.value = '';
    priority.value = '';
    keyDelayEvents.value = '';
    affectedMilestone.value = '';
    briefDetails.text = '';
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
