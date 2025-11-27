import 'package:ashishinterbuild/app/modules/global_controller/acc_category/acc_category_controller.dart';
import 'package:get/get.dart';

class AccCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccCategoryController>(() => AccCategoryController());
  }
}
