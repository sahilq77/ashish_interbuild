import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/project_name/get_project_name_dropdown_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectNameDropdownController extends GetxController {
  RxList<ProjectData> projectList = <ProjectData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedProjectVal; // ← renamed from selectedZoneVal

  static ProjectNameDropdownController get to => Get.find();

  // Helper to expose only project names for UI
  List<String> get projectNames => projectList.map((p) => p.projectName).toList();

  @override
  void onInit() {
    super.onInit();
    // Optional: auto-fetch on init if needed
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Get.context != null) {
    //     fetchProjects(context: Get.context!);
    //   }
    // });
  }

  /// Fetch the list of projects from the server
  Future<void> fetchProjects({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    log("ProjectNameDropdown API call");

    if (!forceFetch && projectList.isNotEmpty) return;

    try {
      projectList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Networkcall().getMethod(
            Networkutility.getProjectNameDropdownApi,
            Networkutility.getProjectNameDropdown,
            context,
          ) as List<GetProjectDropdownResponse>?;

      log(
        'Fetch Projects Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          projectList.value = response[0].data as List<ProjectData>;
          log(
            'Project List Loaded: ${projectList.map((p) => "${p.projectName}: ${p.projectId}").toList()}',
          );
        } else {
          errorMessage.value = response[0].message ?? 'Failed to load projects';
          Get.snackbar(
            'Error',
            response[0].message ?? 'Failed to load projects',
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
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.redColor, colorText: Colors.white);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.redColor, colorText: Colors.white);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar('Error', '${e.message} (Code: ${e.statusCode})',
          backgroundColor: AppColors.redColor, colorText: Colors.white);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Error', e.message,
          backgroundColor: AppColors.redColor, colorText: Colors.white);
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch Projects Exception: $e, stack: $stackTrace');
      Get.snackbar('Error', 'Unexpected error occurred',
          backgroundColor: AppColors.redColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a **unique** list of project IDs as strings
  List<String> getProjectIds() {
    return projectList.map((p) => p.projectId.toString()).toSet().toList();
  }

  /// Find project name by its ID
  String? getProjectNameById(String projectId) {
    return projectList
            .firstWhereOrNull((p) => p.projectId.toString() == projectId)
            ?.projectName ??
        '';
  }

  /// Find project ID by its name
  String? getProjectIdByName(String projectName) {
    return projectList
        .firstWhereOrNull((p) => p.projectName == projectName)
        ?.projectId
        .toString();
  }
}