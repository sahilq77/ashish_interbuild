import 'package:get/get.dart';
import 'add_acc_form_controller.dart';

class AddAccFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAccIssueFormController>(() => AddAccIssueFormController());
  }
}