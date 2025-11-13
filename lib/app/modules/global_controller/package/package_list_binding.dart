import 'package:ashishinterbuild/app/modules/global_controller/package/package_list_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:get/get.dart';

class PackageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageListController>(() => PackageListController());
  }
}
