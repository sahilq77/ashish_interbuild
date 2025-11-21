import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/weekly_inspection/get_weekly_inspection_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WeeklyInspectionDashboardController extends GetxController {
  var wirCount = <WirCounts>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString imageLink = "".obs;
  RxString packageName = "".obs;
  RxInt projectId = 0.obs;
  RxInt packageId = 0.obs;
  
  // Dynamic week date filters
  RxString filterInspectionFromDate = ''.obs;
  RxString filterInspectionToDate = ''.obs;

  // Expose individual reactive values derived from wirCount.first
  late RxDouble monthlyTarget;
  late RxDouble monthlyAchieve;
  late RxDouble monthlyPercent;

  late RxDouble weeklyTarget;
  late RxDouble weeklyAchieve;
  late RxDouble weeklyPercent;

  late RxDouble dailyTarget;
  late RxDouble dailyAchieve;
  late RxDouble dailyPercent;
  // final UpdateProgressReportController dprUpdateController = Get.find();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    projectId.value = args?["project_id"] ?? 0;
    packageId.value = args?["package_id"] ?? 0;

    log(
      "WI Dashboard → projectId=${projectId.value} packageId=${packageId.value}",
    );

    // Initialize reactive variables with default values
    _initializeReactiveValues();

    // Set current week dates
    _setCurrentWeekDates();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDashboardData(context: Get.context!);
    });
  }

  void _initializeReactiveValues() {
    monthlyTarget = 0.0.obs;
    monthlyAchieve = 0.0.obs;
    monthlyPercent = 0.0.obs;

    weeklyTarget = 0.0.obs;
    weeklyAchieve = 0.0.obs;
    weeklyPercent = 0.0.obs;

    dailyTarget = 0.0.obs;
    dailyAchieve = 0.0.obs;
    dailyPercent = 0.0.obs;
  }
  
  void _setCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    filterInspectionFromDate.value = DateFormat('yyyy-MM-dd').format(startOfWeek);
    filterInspectionToDate.value = DateFormat('yyyy-MM-dd').format(endOfWeek);
  }

  Future<void> fetchDashboardData({
    required BuildContext context,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        wirCount.clear();
      }

      final response =
          await Networkcall().getMethod(
                Networkutility.getWIRdashboardApi,
                "${Networkutility.getWIRdashboard}?project_id=$projectId&filter_package=$packageId&start=0&length=10&filter_inspection_from_date=${filterInspectionFromDate.value}&filter_inspection_to_date=${filterInspectionToDate.value}",
                context,
              )
              as List<GetWeeklyDashboard>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == true) {
        final count = response[0].wirCounts;

        wirCount.add(count);
        log("${monthlyTarget.value}");
        // Update all reactive values from the API response
        monthlyTarget.value =
            double.tryParse(count.totalTarget.toString() ?? '0') ?? 0.0;
        monthlyAchieve.value =
            double.tryParse(count.totalAchievedTarget.toString() ?? '0') ?? 0.0;
        monthlyPercent.value =
            double.tryParse(count.totalAchievedTargetPer ?? '0') ?? 0.0;

        weeklyTarget.value =
            double.tryParse(count.monthTarget.toString() ?? '0') ?? 0.0;
        weeklyAchieve.value =
            double.tryParse(count.monthAchievedTarget.toString() ?? '0') ?? 0.0;
        weeklyPercent.value =
            double.tryParse(count.monthAchievedTargetPer.toString() ?? '0') ??
            0.0;

        dailyTarget.value =
            double.tryParse(count.weeklyTarget.toString() ?? '0') ?? 0.0;
        dailyAchieve.value =
            double.tryParse(count.weeklyAchievedTarget.toString() ?? '0') ??
            0.0;
        dailyPercent.value =
            double.tryParse(count.weeklyAchievedTargetPer ?? '0') ?? 0.0;
      } else {
        final message = response?.isNotEmpty == true
            ? response![0].message
            : 'Failed to load data';
        AppSnackbarStyles.showError(title: 'Error', message: message);
        errorMessage.value = message;
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: "Error", message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
    } on ParseException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData(context: Get.context!, isRefresh: true);
  }

  String formatCurrency(double amount) {
    if (amount == 0) return '₹0.00';
    return '₹${amount.toStringAsFixed(2)} '; // or without 'Cr' as needed
  }

  String formatPercentage(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }
}
