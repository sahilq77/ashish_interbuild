import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/week_periods/get_week_periods_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart'; // Add this import
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
                Networkutility.getWeekPeriodsApi,
                Networkutility.getWeekPeriods + "?year=$year",
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
          final selectedPeriod = periodsList.firstWhereOrNull(
            (p) => p.isSelected == "1",
          );
          if (selectedPeriod != null) {
            selectedPeriodVal.value = selectedPeriod.label;
            log('Auto-selected period: ${selectedPeriod.label}');

            // Optional: Show success snackbar when data loads successfully
            // AppSnackbarStyles.showSuccess(
            //   title: "Success",
            //   message: "Weekly periods loaded successfully",
            // );
          }
        } else {
          errorMessage.value = response[0].message ?? "Failed to load periods";

          AppSnackbarStyles.showError(
            title: "Error",
            message: response[0].message ?? "Failed to load weekly periods",
          );
        }
      } else {
        errorMessage.value = 'No data received from server';

        AppSnackbarStyles.showWarning(
          title: "No Data",
          message: "No weekly periods found for the selected year",
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;

      AppSnackbarStyles.showError(title: "No Internet", message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;

      AppSnackbarStyles.showError(
        title: "Request Timeout",
        message: "The server took too long to respond",
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';

      AppSnackbarStyles.showError(
        title: "Server Error",
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;

      AppSnackbarStyles.showError(
        title: "Data Error",
        message: "Failed to process server response",
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch WeeklyPeriods Exception: $e\nStack: $stackTrace');

      AppSnackbarStyles.showError(
        title: "Something Went Wrong",
        message: "Please try again later",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rest of your helper methods remain unchanged...
  List<String> getPeriodCodes() {
    return periodsList.map((p) => p.weekCode.toString()).toSet().toList();
  }

  String getPeriodLabelByCode(String weekCode) {
    return periodsList
            .firstWhereOrNull((p) => p.weekCode.toString() == weekCode)
            ?.label ??
        weekCode;
  }

  String? getPeriodCodeByLabel(String label) {
    return periodsList
        .firstWhereOrNull((p) => p.label == label)
        ?.weekCode
        .toString();
  }

  WeeklyPeriod? getPeriodByCode(String weekCode) {
    return periodsList.firstWhereOrNull(
      (p) => p.weekCode.toString() == weekCode,
    );
  }

  WeeklyPeriod? getSelectedPeriod() {
    return periodsList.firstWhereOrNull((p) => p.isSelected == "1");
  }
}
