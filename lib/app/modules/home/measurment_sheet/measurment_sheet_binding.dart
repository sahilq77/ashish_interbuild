import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:get/get.dart';

class MeasurmentSheetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeasurementSheetController>(() => MeasurementSheetController());
  }
}
