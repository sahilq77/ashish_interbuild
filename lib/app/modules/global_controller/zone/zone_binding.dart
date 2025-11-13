import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:get/get.dart';

class ZoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneController>(() => ZoneController());
  }
}
