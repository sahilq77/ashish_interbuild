import 'package:get/get.dart';
import 'update_acc_form_controller.dart';

class UpdateAccFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateAccFormController>(() => UpdateAccFormController());
  }
}