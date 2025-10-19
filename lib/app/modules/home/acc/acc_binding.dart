import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_project_name/measurment_project_name_controller.dart';
import 'package:get/get.dart';

class AccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeasurmentProjectNameController>(() => MeasurmentProjectNameController());
  }
}
