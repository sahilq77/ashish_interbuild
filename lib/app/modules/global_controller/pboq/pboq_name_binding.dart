import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
import 'package:get/get.dart';

class PboqNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PboqNameController>(() => PboqNameController());
  }
}
