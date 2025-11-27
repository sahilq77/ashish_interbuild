import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/doer_role/get_door_role_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoerRoleController extends GetxController {
  // List of Doer Roles
  RxList<DoerRoleData> doerRoleList = <DoerRoleData>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Selected Doer Role (stored as String for dropdowns, etc.)
  RxString? selectedDoerRoleVal = "".obs;

  static DoerRoleController get to => Get.find();

  // Helper: expose only role names for UI (e.g., DropdownMenu items)
  List<String> get doerRoleNames =>
      doerRoleList.map((r) => r.roleName).toList();

  @override
  void onInit() {
    super.onInit();
    // Optional: auto-fetch when controller is initialized
    // fetchDoerRoles(context: Get.context!);
  }

  /// Fetch the list of Doer Roles from the server
  Future<void> fetchDoerRoles({
    required BuildContext context,
    bool forceFetch = false,
    int projectId = 0,
    int packageId = 0,
    int pboqId = 0,
  }) async {
    log("DoerRole API call");

    if (!forceFetch && doerRoleList.isNotEmpty) return;

    try {
      doerRoleList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility.getDoerRoleApi,
                Networkutility.getDoerRole,
                context,
              )
              as List<GetDoerRoleResponse>?;

      log(
        'Fetch DoerRole Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          doerRoleList.value = response[0].data as List<DoerRoleData>;

          log(
            'DoerRole List Loaded: ${doerRoleList.map((r) => "${r.roleName}: ${r.doerRoleId}").toList()}',
          );
        } else {
          errorMessage.value =
              response[0].message ?? "Failed to load doer roles";
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
      log('Fetch DoerRole Exception: $e\nStackTrace: $stackTrace');
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

  /// Returns a unique list of DoerRole IDs as strings
  List<String> getDoerRoleIds() {
    return doerRoleList.map((r) => r.doerRoleId.toString()).toSet().toList();
  }

  /// Find role name by its ID
  String? getDoerRoleNameById(String doerRoleId) {
    return doerRoleList
        .firstWhereOrNull((r) => r.doerRoleId.toString() == doerRoleId)
        ?.roleName;
  }

  /// Find role ID by its name
  String? getDoerRoleIdByName(String roleName) {
    return doerRoleList
        .firstWhereOrNull((r) => r.roleName == roleName)
        ?.doerRoleId
        .toString();
  }

  /// Clear selected Doer Role
  void clearSelectedDoerRole() {
    selectedDoerRoleVal = null;
  }
}
