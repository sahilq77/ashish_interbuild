import 'dart:convert';
import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/packages/get_package_name_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackageNameController extends GetxController {
  RxList<PackageData> packageList = <PackageData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedPackageVal;

  static PackageNameController get to => Get.find();

  // Helper to expose only package names for UI
  List<String> get packageNames =>
      packageList.map((p) => p.packageName).toList();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchPackages(context: Get.context!);
      }
    });
  }

  Future<void> fetchPackages({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    log("PackageData API call");
    if (!forceFetch && packageList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility.getPackagesListApi,
                Networkutility.getPackagesList,
                context,
              )
              as List<GetPackageNameResponse>?;

      log(
        'Fetch PackageData Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          packageList.value = response[0].data as List<PackageData>;
          log(
            'PackageData List Loaded: ${packageList.map((s) => "${s.packageName}: ${s.packageId}").toList()}',
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
      log('Fetch PackageData Exception: $e, stack: $stackTrace');
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

  List<String> getPackageIds() {
    return packageList.map((s) => s.packageId.toString()).toSet().toList();
  }

  String? getPackageNameById(String packageId) {
    return packageList
            .firstWhereOrNull((p) => p.packageId.toString() == packageId)
            ?.packageName ??
        '';
  }

  String? getPackageIdByName(String packageName) {
    return packageList
        .firstWhereOrNull((p) => p.packageName == packageName)
        ?.packageId
        .toString();
  }
}
