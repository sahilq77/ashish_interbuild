import 'package:ashishinterbuild/app/modules/global_controller/milestone/milestone_controller.dart' show MilestoneController;
import 'package:get/get.dart';

class MilestoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MilestoneController>(() => MilestoneController());
  }
}
