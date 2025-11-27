import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/milestone/get_milestone_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MilestoneController extends GetxController {
  // List of Milestones
  RxList<MilestoneData> milestoneList = <MilestoneData>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Selected Milestone (stored as String for dropdowns, etc.)
  RxString? selectedMilestoneVal = "".obs;

  static MilestoneController get to => Get.find();

  // Helper: expose only milestone descriptions for UI (e.g., DropdownMenu items)
  List<String> get milestoneNames => milestoneList.map((m) => m.descr).toList();

  @override
  void onInit() {
    super.onInit();
    // Optional: auto-fetch when controller is initialized
    // fetchMilestones(context: Get.context!);
  }

  /// Fetch the list of Milestones from the server
  Future<void> fetchMilestones({
    required BuildContext context,
    bool forceFetch = false,
    int projectId = 0,
    int packageId = 0,
    int pboqId = 0,
  }) async {
    log("Milestone API call");

    if (!forceFetch && milestoneList.isNotEmpty) return;

    try {
      milestoneList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility.getMilestonesApi,
                Networkutility.getMilestones,
                context,
              )
              as List<GetMilestoneResponse>?;

      log(
        'Fetch Milestone Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          milestoneList.value = response[0].data as List<MilestoneData>;

          log(
            'Milestone List Loaded: ${milestoneList.map((m) => "${m.descr}: ${m.milestoneId}").toList()}',
          );
        } else {
          errorMessage.value =
              response[0].message ?? "Failed to load milestones";
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
        'HTTP Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Parse Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch Milestone Exception: $e\nStackTrace: $stackTrace');
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

  /// Returns a unique list of Milestone IDs as strings
  List<String> getMilestoneIds() {
    return milestoneList.map((m) => m.milestoneId.toString()).toSet().toList();
  }

  /// Find milestone description by its ID
  String? getMilestoneNameById(String milestoneId) {
    return milestoneList
        .firstWhereOrNull((m) => m.milestoneId.toString() == milestoneId)
        ?.descr;
  }

  /// Find milestone ID by its description
  String? getMilestoneIdByName(String descr) {
    return milestoneList
        .firstWhereOrNull((m) => m.descr == descr)
        ?.milestoneId
        .toString();
  }

  /// Clear selected Milestone
  void clearSelectedMilestone() {
    selectedMilestoneVal = null;
  }
}
