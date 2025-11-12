import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:ashishinterbuild/app/modules/home/work_front_update/work_front_update_list_view/work_front_update_list_controller.dart';
import 'package:get/get.dart';

class WorkFrontUpdateListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkFrontUpdateListController>(
      () => WorkFrontUpdateListController(),
    );
  }
}
