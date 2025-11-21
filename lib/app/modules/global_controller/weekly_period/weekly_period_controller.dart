import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/week_periods/get_week_periods_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeeklyPeriodController extends GetxController {
  RxList<WeeklyPeriod> periodsList = <WeeklyPeriod>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Selected weekly period value (label or code depending on your UI)
  RxString selectedPeriodVal = "".obs;

  static WeeklyPeriodController get to => Get.find();

  // Helper to expose only period labels for dropdown/UI
  List<String> get periodLabels => periodsList.map((p) => p.label).toList();

  @override
  void onInit() {
    super.onInit();
    // Optionally auto-fetch on init if needed
  }

  /// Fetch the list of weekly periods from the server
  Future<void> fetchPeriods({
    required BuildContext context,
    bool forceFetch = false,
    int year = 0,
  }) async {
    log("WeeklyPeriod API call - Year: $year");

    if (!forceFetch && periodsList.isNotEmpty) return;

    try {
      periodsList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility
                    .getWeekPeriodsApi, // Make sure this constant exists
                Networkutility.getWeekPeriods +
                    "?year=$year", // Update this URL constant too
                context,
              )
              as List<GetWeeklyPeriodsResponse>?;

      log(
        'Fetch WeeklyPeriods Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          periodsList.value = response[0].data as List<WeeklyPeriod>;
          log(
            'Weekly Periods Loaded: ${periodsList.map((p) => "${p.label}: ${p.weekCode}").toList()}',
          );
          
          // Auto-select period if is_selected is "1"
          final selectedPeriod = periodsList.firstWhereOrNull((p) => p.isSelected == "1");
          if (selectedPeriod != null) {
            selectedPeriodVal.value = selectedPeriod.label;
            log('Auto-selected period: ${selectedPeriod.label}');
          }
        } else {
          errorMessage.value = response[0].message ?? "Failed to load periods";
          Get.snackbar(
            'Error',
            response[0].message ?? "Unknown error",
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'No data received from server';
        Get.snackbar(
          'No Data',
          'No weekly periods found',
          backgroundColor: AppColors.redColor,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'No Internet',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Timeout',
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
      log('Fetch WeeklyPeriods Exception: $e\nStack: $stackTrace');
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a unique list of week codes as strings
  List<String> getPeriodCodes() {
    return periodsList.map((p) => p.weekCode.toString()).toSet().toList();
  }

  /// Find period label by week code
  String getPeriodLabelByCode(String weekCode) {
    return periodsList
            .firstWhereOrNull((p) => p.weekCode.toString() == weekCode)
            ?.label ??
        weekCode;
  }

  /// Find week code by period label
  String? getPeriodCodeByLabel(String label) {
    return periodsList
        .firstWhereOrNull((p) => p.label == label)
        ?.weekCode
        .toString();
  }

  /// Optional: Get WeeklyPeriod object by code
  WeeklyPeriod? getPeriodByCode(String weekCode) {
    return periodsList.firstWhereOrNull(
      (p) => p.weekCode.toString() == weekCode,
    );
  }

  /// Get the currently selected period (where is_selected == "1")
  WeeklyPeriod? getSelectedPeriod() {
    return periodsList.firstWhereOrNull((p) => p.isSelected == "1");
  }
}
