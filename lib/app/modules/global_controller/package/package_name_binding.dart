import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:get/get.dart';

class PackageNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageNameController>(() => PackageNameController());
  }
}
