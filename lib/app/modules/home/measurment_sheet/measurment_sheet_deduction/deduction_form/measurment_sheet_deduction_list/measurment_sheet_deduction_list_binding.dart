import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_deduction/deduction_form/measurment_sheet_deduction_list/measurment_sheet_deduction_list_controller.dart';
import 'package:get/get.dart';

class MeasurmentSheetDeductionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeasurmentSheetDeductionListController>(
      () => MeasurmentSheetDeductionListController(),
    );
  }
}
