import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_deduction/deduction_form/deduction_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_details_list.dart';
import 'package:get/get.dart';


class DeductionFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeductionFormController>(() => DeductionFormController());
  }
}
