import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/edit_pboq/edit_pboq_form_controller.dart';
import 'package:get/get.dart';

class EditPboqFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPboqFormController>(() => EditPboqFormController());
  }
}
