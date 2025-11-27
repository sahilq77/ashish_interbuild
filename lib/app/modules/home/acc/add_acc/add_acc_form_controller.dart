import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  final RxString attachmentFileName = 'No file chosen'.obs;

  final projectdController = Get.find<ProjectNameDropdownController>();
  final packageNameController = Get.find<PackageNameController>();
  final accCategoryController = Get.find<AccCategoryController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        // zoneController.fetchZones(context: Get.context!);
        projectdController.fetchProjects(context: Get.context!);
        accCategoryController.fetchAccCategories(context: Get.context!);
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

  void pickAttachment() {
    // Simulate file picking (replace with actual file picker logic)
    attachmentFileName.value = 'Selected File.pdf'; // Dummy file name
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
}
