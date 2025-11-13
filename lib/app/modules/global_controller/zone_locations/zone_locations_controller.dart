import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_locations_response.dart';
import 'package:ashishinterbuild/app/data/models/global_model/zone/get_zone_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZoneLocationController extends GetxController {
  /// List of zone-location items
  RxList<ZoneLocationData> zoneLocationList = <ZoneLocationData>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// Selected zone-location value (renamed from selectedZoneVal)
  RxString? selectedZoneLocationVal;

  static ZoneLocationController get to => Get.find();

  // Helper to expose only zone-location names for UI
  List<String> get zoneLocationNames =>
      zoneLocationList.map((z) => z.locationName).toList();

  @override
  void onInit() {
    super.onInit();
    // Uncomment if you want to fetch on init
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Get.context != null) {
    //     fetchZoneLocations(context: Get.context!);
    //   }
    // });
  }

  /// Fetch the list of zone-locations from the server
  Future<void> fetchZoneLocations({
    required BuildContext context,
    bool forceFetch = false,
    int projectId = 0,
    int packageId = 0,
    int pboqId = 0,
    int zoneId = 0,
  }) async {
    log("ZoneLocationData API call");

    if (!forceFetch && zoneLocationList.isNotEmpty) return;

    try {
      zoneLocationList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await Networkcall().getMethod(
                Networkutility.getZoneLocationsApi,
                projectId == 0 && packageId == 0 && pboqId == 0
                    ? Networkutility.getZoneLocations
                    : "${Networkutility.getZoneLocations}"
                          "?project_id=$projectId&pboq_id=$pboqId&package_id=$packageId&zone_id=$zoneId",
                context,
              )
              as List<GetZoneLocationsResponse>?;

      log(
        'Fetch ZoneLocationData Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          zoneLocationList.value = response[0].data as List<ZoneLocationData>;

          log(
            'ZoneLocation List Loaded: ${zoneLocationList.map((s) => "${s.locationName}: ${s.zoneLocationId}").toList()}',
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
      log('Fetch ZoneLocationData Exception: $e, stack: $stackTrace');
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

  /// Returns a **unique** list of zone-location IDs as strings
  List<String> getZoneLocationIds() {
    return zoneLocationList
        .map((s) => s.zoneLocationId.toString())
        .toSet()
        .toList();
  }

  /// Find zone-location name by its ID
  String? getZoneLocationNameById(String zoneLocationId) {
    return zoneLocationList
            .firstWhereOrNull(
              (z) => z.zoneLocationId.toString() == zoneLocationId,
            )
            ?.locationName ??
        '';
  }

  /// Find zone-location ID by its name
  String? getZoneLocationIdByName(String locationName) {
    return zoneLocationList
        .firstWhereOrNull((z) => z.locationName == locationName)
        ?.zoneLocationId
        .toString();
  }
}
