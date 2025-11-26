import 'package:ashishinterbuild/app/modules/global_controller/package/package_list_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:get/get.dart';

class ProjectNameDropdownBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectNameDropdownController>(() => ProjectNameDropdownController());
  }
}
