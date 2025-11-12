import 'package:ashishinterbuild/app/modules/home/acc/edit_acc/edit_acc_controller.dart';
import 'package:get/get.dart';


class EditAccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditAccController>(() => EditAccController());
  }
}