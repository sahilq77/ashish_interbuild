import 'dart:convert';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_add_deduction_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_delete_measurement_sheet_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart'
    show Networkcall;
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeductionFormController extends GetxController {
  final TextEditingController nosController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final MeasurementSheetController mesurmentCtrl = Get.find();
  final pboqcontroller = Get.find<PboqMeasurmentDetailController>();
  final RxBool isLoadingd = true.obs;
  var nos = ''.obs;
  var length = ''.obs;
  var breadth = ''.obs;
  var height = ''.obs;
  var calculatedQty = '0.00'.obs;
  var msId = ''.obs;
  var pboq_id = 0.obs;

  final TextEditingController calculatedQtyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Get msId from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      msId.value = args['ms_id'] ?? '';
      pboq_id.value = args['pboq_id'] ?? '';
    }

    nosController.addListener(() {
      nos.value = nosController.text;
      calculateQuantity();
    });
    lengthController.addListener(() {
      length.value = lengthController.text;
      calculateQuantity();
    });
    breadthController.addListener(() {
      breadth.value = breadthController.text;
      calculateQuantity();
    });
    heightController.addListener(() {
      height.value = heightController.text;
      calculateQuantity();
    });

    // Listen to calculatedQty changes and update controller
    ever(calculatedQty, (value) => calculatedQtyController.text = value);
  }

  @override
  void onClose() {
    nosController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
    calculatedQtyController.dispose();
    super.onClose();
  }

  void calculateQuantity() {
    final double? nosVal = nos.value.isEmpty
        ? null
        : double.tryParse(nos.value);
    final double? lengthVal = length.value.isEmpty
        ? null
        : double.tryParse(length.value);
    final double? breadthVal = breadth.value.isEmpty
        ? null
        : double.tryParse(breadth.value);
    final double? heightVal = height.value.isEmpty
        ? null
        : double.tryParse(height.value) ?? 1;

    final List<double> values = [
      if (nosVal != null) nosVal,
      if (lengthVal != null) lengthVal,
      if (breadthVal != null) breadthVal,
      if (heightVal != null) heightVal,
    ];

    if (values.isEmpty) {
      calculatedQty.value = '0.00';
      return;
    }

    double result = values.reduce((a, b) => a * b);
    calculatedQty.value = result.toStringAsFixed(2);
  }

  Future<void> onRefresh() async {
    nosController.clear();
    lengthController.clear();
    breadthController.clear();
    heightController.clear();
    nos.value = '';
    length.value = '';
    breadth.value = '';
    height.value = '';
  }

  Future<void> addMeasurmentsheet({
    BuildContext? context,
    required String msId,
  }) async {
    try {
      isLoadingd.value = true;
      final jsonBody = {
        "project_id": mesurmentCtrl.projectId.value,
        "ms_id": int.parse(msId),
        "pboq_id": pboqcontroller.pboqId.value,
        "nos": int.parse(nos.value),
        "length": int.parse(length.value),
        "breadth": int.parse(breadth.value),
        "height": int.parse(height.value),
      };
      log(jsonEncode(jsonBody));
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.addDeductionsApi,
        Networkutility.addDeductions,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetAddDeductionResponse> response =
            getAddDeductionResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: 'Deduction added successfully',
          );
        } else {
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to add Deduction");

          AppSnackbarStyles.showError(title: 'Failed', message: errorMessage);
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Failed',
          message: "No response from server",
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'Unexpected Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoadingd.value = false;
      // Refresh the list after successful deletion
    }
  }

  void submitForm() {
    if (nos.value.isEmpty ||
        length.value.isEmpty ||
        breadth.value.isEmpty ||
        height.value.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please fill all required fields',
      );
      return;
    }

    addMeasurmentsheet(msId: msId.value);
  }
}
