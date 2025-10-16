import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:get/get.dart';

class DailyProgressReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyProgressReportController>(
      () => DailyProgressReportController(),
    );
  }
}
