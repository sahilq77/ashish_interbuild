import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_project_name/measurment_project_name_binding.dart';
import 'package:get/get.dart';

class AccProjectListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeasurmentProjectNameBinding>(() => MeasurmentProjectNameBinding());
  }
}
