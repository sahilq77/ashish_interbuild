import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/edit_client_commitment/edit_client_commitment_controller.dart';
import 'package:get/get.dart';

class EditClientCommitmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditClientCommitmentController>(() => EditClientCommitmentController());
  }
}