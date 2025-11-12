import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_controller.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/cliient_commitment_dashboard/client_commitment_dashboard_controller.dart';
import 'package:get/get.dart';

class ClientCommitmentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientCommitmentDashboardController>(
      () => ClientCommitmentDashboardController(),
    );
  }
}
