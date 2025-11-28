import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ashishinterbuild/app/data/models/acc/get_update_submit_response.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_controller.dart'
    show MilestoneController;
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart'
    show AppSnackbarStyles;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/app_colors.dart';

class AccFieldSet {
  // Reactive fields
  var selectedProject = ''.obs;
  var selectedPackage = ''.obs;
  var accCategory = ''.obs;
  var priority = ''.obs;
  var keyDelayEvents = ''.obs;
  var affectedMilestone = ''.obs;
  var briefDetails = ''.obs;
  var role = ''.obs;
  var attachmentFile = Rxn<PlatformFile>();
  var attachmentFileName = 'No file chosen'.obs;

  // Non-reactive: These are managed objects
  var issueOpenDate = DateTime.now().obs;

  // This controller is created once and reused
  late final TextEditingController dateController;

  AccFieldSet() {
    // Initialize once
    dateController = TextEditingController(
      text: issueOpenDate.value.toLocal().toString().split(' ')[0],
    );

    // Auto-update text when date changes
    ever(issueOpenDate, (DateTime date) {
      dateController.text = date.toLocal().toString().split(' ')[0];
    });
  }

  // Clean up controller
  void dispose() {
    dateController.dispose();
  }

  // Helper: Check if this row is valid
  bool get isValid {
    return selectedProject.value.isNotEmpty &&
        selectedPackage.value.isNotEmpty &&
        accCategory.value.isNotEmpty &&
        affectedMilestone.value.isNotEmpty &&
        briefDetails.value.trim().isNotEmpty &&
        issueOpenDate.value.year > 2000 &&
        role.value.isNotEmpty;
  }
}

class AddAccIssueFormController extends GetxController {
  RxBool isLoading = false.obs;
  final RxList<String> priorities = ['Critical', 'High', 'Medium', 'Low'].obs;
  final RxList<String> keyDelayOptions = ['Yes', 'No'].obs;

  // Dynamic field sets
  final fieldSets = <AccFieldSet>[].obs;

  // Global controllers
  late final ProjectNameDropdownController projectdController;
  late final PackageNameController packageNameController;
  late final AccCategoryController accCategoryController;
  late final DoerRoleController doerRoleController;
  late final MilestoneController milestoneController;
  final AccController listController = Get.put(AccController());

  @override
  void onInit() {
    super.onInit();

    // Initialize dependencies
    projectdController = Get.find<ProjectNameDropdownController>();
    packageNameController = Get.find<PackageNameController>();
    accCategoryController = Get.find<AccCategoryController>();
    doerRoleController = Get.find<DoerRoleController>();
    milestoneController = Get.find<MilestoneController>();

    // Start with one empty row
    addFieldSet();

    // Load dropdown data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        projectdController.fetchProjects(context: Get.context!);
        accCategoryController.fetchAccCategories(context: Get.context!);
        doerRoleController.fetchDoerRoles(context: Get.context!);
        milestoneController.fetchMilestones(context: Get.context!);
      }
    });
  }

  // ========= FIELD CHANGE HANDLERS =========
  void onProjectChanged(int index, String? value) async {
    final fs = fieldSets[index];
    fs.selectedProject.value = value ?? '';
    fs.selectedPackage.value = ''; // Reset package

    if (value != null && value.isNotEmpty) {
      final projectId = projectdController.getProjectIdByName(value);
      if (projectId != null) {
        await packageNameController.fetchPackages(
          context: Get.context!,
          forceFetch: true,
          projectId: int.parse(projectId),
        );
      }
    }
  }

  void onPackageChanged(int index, String? value) {
    fieldSets[index].selectedPackage.value = value ?? '';
  }

  void onAccCategoryChanged(int index, String? value) {
    fieldSets[index].accCategory.value = value ?? '';
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

  // ========= FILE PICKER =========
  Future<void> pickAttachment(int index) async {
    await pickFile(index, allowMultiple: false);
  }

  // ========= ADD / REMOVE ROWS =========
  void addFieldSet() {
    fieldSets.add(AccFieldSet());
  }

  void removeFieldSet(int index) {
    if (fieldSets.length <= 1) {
      // Just clear the first one
      clearFieldSet(0);
      Get.snackbar(
        "Info",
        "At least one row is required",
        backgroundColor: Colors.blue,
      );
    } else {
      fieldSets[index].dispose(); // Important: free controller
      fieldSets.removeAt(index);
    }
  }

  void clearFieldSet(int index) {
    final fs = fieldSets[index];
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

  // ========= SUBMIT FORM =========
  void submitForm(BuildContext context) async {
    // Validate all field sets
    for (int i = 0; i < fieldSets.length; i++) {
      if (!fieldSets[i].isValid) {
        Get.snackbar(
          "Missing Fields",
          "Please complete all required fields in row ${i + 1}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    isLoading.value = true;

    try {
      // Prepare form data and files
      var formData = <String, String>{};
      var fileMap = <String, File>{};

      for (int i = 0; i < fieldSets.length; i++) {
        final fs = fieldSets[i];

        // Get IDs using your global controllers
        final projectId = projectdController.getProjectIdByName(
          fs.selectedProject.value,
        );
        final packageId = packageNameController.getPackageIdByName(
          fs.selectedPackage.value,
        );
        final categoryId = accCategoryController.getAccCategoryIdByName(
          fs.accCategory.value,
        );
        final milestoneId = milestoneController.getMilestoneIdByName(
          fs.affectedMilestone.value,
        );
        final doerId = doerRoleController.getDoerRoleIdByName(fs.role.value);

        if (packageId == null ||
            categoryId == null ||
            milestoneId == null ||
            doerId == null) {
          Get.snackbar(
            "Error",
            "Invalid selection in row ${i + 1}. Please reselect.",
          );
          isLoading.value = false;
          return;
        }

        // Map fields to API keys
        formData['acc_data[$i][project_id]'] = projectId ?? "";
        formData['acc_data[$i][acc_packages]'] = packageId;
        formData['acc_data[$i][acc_categories]'] = categoryId;
        formData['acc_data[$i][priority]'] = fs.priority.value.isEmpty
            ? 'Medium'
            : fs.priority.value;
        formData['acc_data[$i][details]'] = fs.briefDetails.value
            .trim(); // Main description
        formData['acc_data[$i][event_details]'] =
            fs.keyDelayEvents.value == 'Yes'
            ? '1'
            : '0'; // Optional: better key
        // OR if backend strictly wants "event_details" for Yes/No too:
        // formData['acc_data[$i][event_details]'] = fs.keyDelayEvents.value; // override if needed

        formData['acc_data[$i][milestones]'] = milestoneId;
        formData['acc_data[$i][doers]'] = doerId;
        formData['acc_data[$i][open_since]'] = fs.issueOpenDate.value
            .toIso8601String()
            .split('T')
            .first;

        // Add attachment if exists
        if (fs.attachmentFile.value != null &&
            fs.attachmentFile.value!.path != null) {
          final file = File(fs.attachmentFile.value!.path!);
          if (await file.exists()) {
            fileMap['attachment_file[$i]'] = file;
          }
        }
      }

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

  // ========= REFRESH =========
  Future<void> onRefresh() async {
    fieldSets.clear();
    addFieldSet();
    Get.snackbar("Refreshed", "Form has been reset");
  }

  // ========= FILE PICKER WITH PERMISSIONS =========
  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final deviceInfo = DeviceInfoPlugin();
    bool granted = false;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        var status = await Permission.photos.request();
        if (status.isDenied) status = await Permission.photos.request();
        granted = status.isGranted;
      } else {
        var status = await Permission.storage.request();
        granted = status.isGranted;
      }
    } else {
      var status = await Permission.photos.request();
      granted = status.isGranted;
    }

    if (!granted) {
      Get.snackbar("Permission Denied", "Cannot pick files without access");
    }
    return granted;
  }

  Future<void> pickFile(int index, {bool allowMultiple = false}) async {
    if (!await _requestStoragePermission()) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: allowMultiple,
      );

      if (result?.files.isNotEmpty ?? false) {
        final file = result!.files.first;
        fieldSets[index].attachmentFile.value = file;
        fieldSets[index].attachmentFileName.value = file.name;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick file");
      log("File picker error: $e");
    }
  }

  // ========= CLEANUP =========
  @override
  void onClose() {
    for (final fs in fieldSets) {
      fs.dispose();
    }
    super.onClose();
  }
}
