import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_controller.dart';
import 'package:get/get.dart';

class AddClientCommitmentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAccIssueFormController>(() => AddAccIssueFormController());
  }
}