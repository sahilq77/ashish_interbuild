import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:get/get.dart';

class ZoneLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneLocationController>(() => ZoneLocationController());
  }
}
