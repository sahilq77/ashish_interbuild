
import 'package:ashishinterbuild/app/modules/home/client_commitment/update_client_commitment/update_client_commitment_form_controller.dart';
import 'package:get/get.dart';

class UpdateClientCommitmentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateClientCommitmentFormController>(() => UpdateClientCommitmentFormController());
  }
}