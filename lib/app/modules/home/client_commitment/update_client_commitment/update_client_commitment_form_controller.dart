import 'package:get/get.dart';

class UpdateClientCommitmentFormController extends GetxController {
  final RxString priority = ''.obs;
  final RxList<String> priorities = <String>['Critical', 'High', 'Medium', 'Low'].obs;

  final Rx<DateTime> revisedCompletionDate = DateTime.now().obs;
  final Rx<DateTime> issueCloseDate = DateTime.now().obs;

  final RxString attachmentFileName = 'No file chosen'.obs;
  final RxString remarks = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void onPriorityChanged(String? value) {
    priority.value = value ?? '';
  }

  void onRevisedCompletionDateChanged(DateTime date) {
    revisedCompletionDate.value = date;
  }

  void onIssueCloseDateChanged(DateTime date) {
    issueCloseDate.value = date;
  }

  void pickAttachment() {
    // Simulate file picking (replace with actual file picker logic)
    attachmentFileName.value = 'Selected File.pdf'; // Dummy file name
  }

  void onRemarksChanged(String value) {
    remarks.value = value;
  }

  void submitForm() {
    if (priority.value.isEmpty || attachmentFileName.value == 'No file chosen') {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }
    print('Priority: $priority');
    print('Revised Completion Date: $revisedCompletionDate');
    print('Issue Close Date: $issueCloseDate');
    print('Attachment: $attachmentFileName');
    print('Remarks: $remarks');
    Get.snackbar('Success', 'Form Updated');
  }

  Future<void> onRefresh() async {
    priority.value = '';
    revisedCompletionDate.value = DateTime.now();
    issueCloseDate.value = DateTime.now();
    remarks.value = '';
    attachmentFileName.value = 'No file chosen';
  }
}