import 'package:ashishinterbuild/app/modules/home/work_front_update/work_front_update_dashboard/work_front_update_dashboard_controller.dart';
import 'package:get/get.dart';

class WorkFrontUpdateDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkFrontUpdateDashboardController>(
      () => WorkFrontUpdateDashboardController(),
    );
  }
}
