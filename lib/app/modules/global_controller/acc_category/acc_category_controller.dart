import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/acc_category/get_acc_category_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccCategoryController extends GetxController {
  // List of account categories
  RxList<AccCategoryData> accCategoryList = <AccCategoryData>[].obs;
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  // Selected account category value (as String for dropdowns, etc.)
  RxString? selectedAccCategoryVal;

  static AccCategoryController get to => Get.find();

  // Helper to expose only category names for UI (e.g., Dropdown items)
  List<String> get accCategoryNames => 
      accCategoryList.map((c) => c.accCategoryName).toList();

  @override
  void onInit() {
    super.onInit();
    // Optional: auto-fetch on init if needed
    // fetchAccCategories(context: Get.context!);
  }

  /// Fetch the list of account categories from the server
  Future<void> fetchAccCategories({
    required BuildContext context,
    bool forceFetch = false,
    int projectId = 0,
    int packageId = 0,
    int pboqId = 0,
  }) async {
    log("AccCategory API call");

    if (!forceFetch && accCategoryList.isNotEmpty) return;

    try {
      accCategoryList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Networkcall().getMethod(
        Networkutility.getAccCategoryApi,
        Networkutility.getAccCategory,
        context,
      ) as List<GetAccCategoryResponse>?;

      log(
        'Fetch AccCategory Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          accCategoryList.value = response[0].data as List<AccCategoryData>;
          
          log(
            'AccCategory List Loaded: ${accCategoryList.map((c) => "${c.accCategoryName}: ${c.accCategoryId}").toList()}',
          );
        } else {
          errorMessage.value = response[0].message ?? "Failed to load categories";
          Get.snackbar(
            'Error',
            response[0].message ?? "Unknown error",
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No data received',
          backgroundColor: AppColors.redColor,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('No Internet', e.message, backgroundColor: AppColors.redColor, colorText: Colors.white);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Timeout', e.message, backgroundColor: AppColors.redColor, colorText: Colors.white);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar('HTTP Error', '${e.message} (Code: ${e.statusCode})',
          backgroundColor: AppColors.redColor, colorText: Colors.white);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Parse Error', e.message, backgroundColor: AppColors.redColor, colorText: Colors.white);
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch AccCategory Exception: $e\nStackTrace: $stackTrace');
      Get.snackbar('Error', 'Something went wrong', backgroundColor: AppColors.redColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a unique list of accCategory IDs as strings
  List<String> getAccCategoryIds() {
    return accCategoryList
        .map((c) => c.accCategoryId.toString())
        .toSet()
        .toList();
  }

  /// Find category name by its ID
  String? getAccCategoryNameById(String accCategoryId) {
    return accCategoryList.firstWhereOrNull(
          (c) => c.accCategoryId.toString() == accCategoryId,
        )?.accCategoryName;
  }

  /// Find category ID by its name
  String? getAccCategoryIdByName(String accCategoryName) {
    return accCategoryList
        .firstWhereOrNull((c) => c.accCategoryName == accCategoryName)
        ?.accCategoryId
        .toString();
  }

  // Optional: Clear selected value
  void clearSelected() {
    selectedAccCategoryVal = null;
  }
}