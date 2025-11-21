import 'package:ashishinterbuild/app/modules/global_controller/weekly_period/weekly_period_controller.dart';
import 'package:get/get.dart';

class WeeklyPeriodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeeklyPeriodController>(() => WeeklyPeriodController());
  }
}
