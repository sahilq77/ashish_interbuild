import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_controller.dart';
import 'package:get/get.dart';

class MeasurmentProjectNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectNameController>(() => ProjectNameController());
  }
}
