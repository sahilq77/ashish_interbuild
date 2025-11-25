import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/work_front_update/get_work_front_dashboard_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkFrontUpdateDashboardController extends GetxController {
  var wfuCount = <WfCounts>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString imageLink = "".obs;
  RxString packageName = "".obs;
  RxInt projectId = 0.obs;
  RxInt packageId = 0.obs;
  // Reactive variables for dashboard data
  final monthlyTarget = RxDouble(0.0);
  final monthlyAchieve = RxDouble(0.0);
  final monthlyPercent = RxDouble(0.0);

  final weeklyTarget = RxDouble(0.0);
  final weeklyAchieve = RxDouble(0.0);
  final weeklyPercent = RxDouble(0.0);

  final dailyTarget = RxDouble(0.0);
  final dailyAchieve = RxDouble(0.0);
  final dailyPercent = RxDouble(0.0);

  @override
  void onInit() {
    super.onInit();
    // Initialize with sample data (replace with actual data source)
    final args = Get.arguments as Map<String, dynamic>?;
    projectId.value = args?["project_id"] ?? 0;
    packageId.value = args?["package_id"] ?? 0;

    log(
      "WFU Dashboard → projectId=${projectId.value} packageId=${packageId.value}",
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDashboardData(context: Get.context!);
    });
  }

  Future<void> fetchDashboardData({
    required BuildContext context,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        wfuCount.clear();
      }

      final response =
          await Networkcall().getMethod(
                Networkutility.getWFUdashboardApi,
                "${Networkutility.getWFUdashboard}?project_id=$projectId&filter_package=$packageId&start=0&length=10",
                context,
              )
              as List<GetWorkFrontUpdateDashboard>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == true) {
        final count = response[0].wfCounts;

        wfuCount.add(count);
        log("${monthlyTarget.value}");
        // Update all reactive values from the API response

        monthlyTarget.value =
            double.tryParse(count.totalTarget.toString() ?? '0') ?? 0.0;
        monthlyAchieve.value =
            double.tryParse(count.totalAchievedTarget.toString() ?? '0') ?? 0.0;
        weeklyPercent.value =
            double.tryParse(count.totalAchievedTargetPer.toString() ?? '0') ??
            0.0;
        // monthlyAchieve.value =
        //     double.tryParse(count.monthAchievedTarget ?? '0') ?? 0.0;
        // monthlyPercent.value =
        //     double.tryParse(count.monthAchievedTargetPer ?? '0') ?? 0.0;

        // weeklyTarget.value = double.tryParse(count.weeklyTarget ?? '0') ?? 0.0;
        // weeklyAchieve.value =
        //     double.tryParse(count.weeklyAchievedTarget ?? '0') ?? 0.0;
        // weeklyPercent.value =
        //     double.tryParse(count.weeklyAchievedTargetPer ?? '0') ?? 0.0;

        // dailyTarget.value = double.tryParse(count.todayTarget ?? '0') ?? 0.0;
        // dailyAchieve.value =
        //     double.tryParse(count.todayAchievedTarget ?? '0') ?? 0.0;
        // dailyPercent.value =
        //     double.tryParse(count.todayAchievedTargetPer ?? '0') ?? 0.0;
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

  double calculatePercentage(double achieved, double target) {
    if (target == 0) return 0.0;
    return (achieved / target * 100).toDouble();
  }

  // Format currency for display
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Format percentage for display
  String formatPercentage(double percent) {
    return '${percent.toStringAsFixed(2)}%';
  }
}
