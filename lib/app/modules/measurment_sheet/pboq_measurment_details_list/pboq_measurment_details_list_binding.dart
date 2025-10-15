import 'package:ashishinterbuild/app/modules/measurment_sheet/pboq_measurment_details_list/pboq_measurment_details_list.dart';
import 'package:get/get.dart';


class PboqMeasurmentDetailsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PboqMeasurmentDetailsList>(() => PboqMeasurmentDetailsList());
  }
}
