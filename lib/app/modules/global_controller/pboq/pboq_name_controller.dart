import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/packages/get_package_name_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/pboq/get_pboq_name_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PboqNameController extends GetxController {
  RxList<PboqData> pboqList = <PboqData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedPboqVal;

  static PboqNameController get to => Get.find();

  // Helper to expose only pboq names for UI
  List<String> get pboqNames => pboqList.map((p) => p.pboqName).toList();

  @override
  void onInit() {
    super.onInit();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Get.context != null) {
    //     fetchPboqs(context: Get.context!);
    //   }
    // });
  }

  /// Fetch the list of PBOQs from the server
  Future<void> fetchPboqs({
    required BuildContext context,
    bool forceFetch = false,
    int projectId = 0,
    int packageId = 0,
  }) async {
    log("PboqData API call");

    if (!forceFetch && pboqList.isNotEmpty) return;

    try {
      pboqList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility.getPboqApi,
                projectId == 0 || packageId == 0
                    ? Networkutility.getPboq
                    : Networkutility.getPboq +
                          "?project_id=$projectId&package_id=$packageId",
                context,
              )
              as List<GetPboqNameResponse>?;

      log(
        'Fetch PboqData Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          pboqList.value = response[0].data as List<PboqData>;
          log(
            'PboqData List Loaded: ${pboqList.map((s) => "${s.pboqName}: ${s.pboqId}").toList()}',
          );
        } else {
          errorMessage.value = response[0].status.toString();
          Get.snackbar(
            'Error',
            response[0].status.toString(),
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.redColor,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch PboqData Exception: $e, stack: $stackTrace');
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a **unique** list of PBOQ IDs as strings
  List<String> getPboqIds() {
    return pboqList.map((s) => s.pboqId.toString()).toSet().toList();
  }

  /// Find PBOQ name by its ID
  String? getPboqNameById(String pboqId) {
    return pboqList
            .firstWhereOrNull((p) => p.pboqId.toString() == pboqId)
            ?.pboqName ??
        '';
  }

  /// Find PBOQ ID by its name
  String? getPboqIdByName(String pboqName) {
    return pboqList
        .firstWhereOrNull((p) => p.pboqName == pboqName)
        ?.pboqId
        .toString();
  }
}
