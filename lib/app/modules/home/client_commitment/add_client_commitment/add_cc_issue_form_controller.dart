import 'package:get/get.dart';

class AddCcIssueFormController extends GetxController {
  final RxString accCategory = ''.obs;
  final RxList<String> accCategories = <String>['Category A', 'Category B', 'Category C'].obs;

  final RxString priority = ''.obs;
  final RxList<String> priorities = <String>['Critical', 'High', 'Medium', 'Low'].obs;

  final RxString keyDelayEvents = ''.obs;
  final RxList<String> keyDelayOptions = <String>['Yes', 'No'].obs;

  final RxString affectedMilestone = ''.obs;
  final RxList<String> milestones = <String>['Milestone 1', 'Milestone 2', 'Milestone 3'].obs;

  final RxString briefDetails = ''.obs;

  final Rx<DateTime> issueOpenDate = DateTime.now().obs;

  final RxString role = ''.obs;
  final RxList<String> roles = <String>['Doer 1', 'Doer 2', 'Doer 3'].obs;

  final RxString hod = ''.obs; // New field for HOD
  final Rx<DateTime> milestoneTargetDate = DateTime.now().obs; // New field for Milestone Target Date
  final RxString attachmentFileName = 'No file chosen'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void onAccCategoryChanged(String? value) {
    accCategory.value = value ?? '';
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

  void onHodChanged(String value) {
    hod.value = value;
  }

  void onMilestoneTargetDateChanged(DateTime date) {
    milestoneTargetDate.value = date;
  }

  void pickAttachment() {
    // Simulate file picking (replace with actual file picker logic)
    attachmentFileName.value = 'Selected File.pdf'; // Dummy file name
  }

  void submitForm() {
    if (role.value.isEmpty ||
        hod.value.isEmpty ||
        accCategory.value.isEmpty ||
        briefDetails.value.isEmpty ||
        issueOpenDate.value == null ||
        priority.value.isEmpty ||
        attachmentFileName.value == 'No file chosen') {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }
    print('Task Assigned To: $role');
    print('HOD: $hod');
    print('CC Category: $accCategory');
    print('Task Details: $briefDetails');
    print('Initial Target Date: $issueOpenDate');
    print('Category: $priority');
    print('Affected Milestone: $affectedMilestone');
    print('Milestone Target Date: $milestoneTargetDate');
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
    hod.value = ''; // Reset HOD
    milestoneTargetDate.value = DateTime.now(); // Reset Milestone Target Date
    attachmentFileName.value = 'No file chosen';
  }
}