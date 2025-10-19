import 'package:get/get.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_controller.dart';

class ClientCommitmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientCommitmentController>(() => ClientCommitmentController());
  }
}
