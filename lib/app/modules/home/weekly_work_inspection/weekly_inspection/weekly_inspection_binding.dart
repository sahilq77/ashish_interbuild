import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_controller.dart';
import 'package:get/get.dart';

class WeeklyInspectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeeklyInspectionController>(() => WeeklyInspectionController());
  }
}
