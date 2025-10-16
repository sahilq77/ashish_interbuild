import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard_controller.dart';
import 'package:get/get.dart';

class DailyProgressReportDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyProgressReportDashboardController>(
      () => DailyProgressReportDashboardController(),
    );
  }
}
