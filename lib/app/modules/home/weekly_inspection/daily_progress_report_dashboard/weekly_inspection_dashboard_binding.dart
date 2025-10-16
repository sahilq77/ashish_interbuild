import 'package:ashishinterbuild/app/modules/home/weekly_inspection/daily_progress_report_dashboard/weekly_inspection_dashboard_controller.dart';
import 'package:get/get.dart';

class WeeklyInspectionDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeeklyInspectionDashboardController>(
      () => WeeklyInspectionDashboardController(),
    );
  }
}
