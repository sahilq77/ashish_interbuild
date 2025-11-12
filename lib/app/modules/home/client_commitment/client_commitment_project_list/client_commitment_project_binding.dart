import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_project_name/project_name_controller.dart';
import 'package:get/get.dart';

class ClientCommitmentProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectNameController>(() => ProjectNameController());
  }
}
