import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/doer_role/doer_role_controller.dart';
import 'package:get/get.dart';

class DoerRoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoerRoleController>(() => DoerRoleController());
  }
}
