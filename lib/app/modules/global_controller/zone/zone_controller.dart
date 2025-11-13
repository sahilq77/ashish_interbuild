import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZoneController extends GetxController {
  RxList<ZoneData> zoneList = <ZoneData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedZoneVal; // ← renamed from selectedPboqVal

  static ZoneController get to => Get.find();

  // Helper to expose only zone names for UI
  List<String> get zoneNames => zoneList.map((z) => z.zoneName).toList();

  @override
  void onInit() {
    super.onInit();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Get.context != null) {
    //     fetchZones(context: Get.context!);
    //   }
    // });
  }

  /// Fetch the list of zones from the server
  Future<void> fetchZones({
    required BuildContext context,
    bool forceFetch = false,
    int projectId = 0,
    int packageId = 0,
    int pboqId = 0,
  }) async {
    log("ZoneData API call");

    if (!forceFetch && zoneList.isNotEmpty) return;

    try {
      zoneList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility.getZonesApi,
                projectId == 0 && packageId == 0 && pboqId == 0
                    ? Networkutility.getZones
                    : Networkutility.getZones +
                          "?project_id=$projectId&pboq_id=$pboqId&package_id=$packageId",
                context,
              )
              as List<GetZoneResponse>?;

      log(
        'Fetch ZoneData Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          zoneList.value = response[0].data as List<ZoneData>;
          log(
            'Zone List Loaded: ${zoneList.map((s) => "${s.zoneName}: ${s.zoneId}").toList()}',
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
      log('Fetch ZoneData Exception: $e, stack: $stackTrace');
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

  /// Returns a **unique** list of zone IDs as strings
  List<String> getZoneIds() {
    return zoneList.map((s) => s.zoneId.toString()).toSet().toList();
  }

  /// Find zone name by its ID
  String? getZoneNameById(String zoneId) {
    return zoneList
            .firstWhereOrNull((z) => z.zoneId.toString() == zoneId)
            ?.zoneName ??
        '';
  }

  /// Find zone ID by its name
  String? getZoneIdByName(String zoneName) {
    return zoneList
        .firstWhereOrNull((z) => z.zoneName == zoneName)
        ?.zoneId
        .toString();
  }
}
