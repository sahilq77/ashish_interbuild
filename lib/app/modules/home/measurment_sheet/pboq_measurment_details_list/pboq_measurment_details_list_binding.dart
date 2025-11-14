import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:get/get.dart';


class PboqMeasurmentDetailsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PboqMeasurmentDetailController>(() => PboqMeasurmentDetailController());
  }
}
