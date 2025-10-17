import 'package:ashishinterbuild/app/modules/home/daily_progress_report/update_progress_report_list/update_progress_report_controller.dart';
import 'package:get/get.dart';

class UpdateWeeklyInspectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateProgressReportController>(
      () => UpdateProgressReportController(),
    );
  }
}
