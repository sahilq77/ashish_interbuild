import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateAccFormController extends GetxController {
  final RxString priority = 'Low'.obs;
  final RxList<String> priorities = <String>[
    'Low',
    'Medium',
    'High',
    'Critical',
  ].obs;

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

  void pickAttachment() {
    // Simulate file picking (replace with actual file picker logic)
    attachmentFileName.value = 'Selected File.pdf'; // Dummy file name
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
}
