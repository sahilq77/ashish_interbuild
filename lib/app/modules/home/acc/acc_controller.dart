import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/acc/acc_model.dart';
import 'package:ashishinterbuild/app/data/models/acc/get_acc_list_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_delete_measurement_sheet_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_name_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_dropdown_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccController extends GetxController {
  final RxList<AccItem> wfuList = <AccItem>[].obs;
  final RxBool isLoadingd = true.obs;
  final RxList<AccItem> filteredMeasurementSheets = <AccItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt expandedIndex = (-1).obs;
  final TextEditingController searchController = TextEditingController();
  final RxInt start = 0.obs;
  final int length = 10;
  final RxString _search = ''.obs;
  final RxString _orderBy = ''.obs;
  final RxBool isAscending = true.obs;
  final RxnString selectedPackageFilter = RxnString(null);
  Timer? _debounce;
  RxInt projectId = 0.obs;
  RxInt packageId = 0.obs;
  final RxList<String> frontDisplayColumns = <String>[].obs;
  final RxList<String> buttonDisplayColumns = <String>[].obs;
  final RxString priority = ''.obs;
  final RxList<String> priorities = <String>['High', 'Medium', 'Low'].obs;

  // FILTERS
  final RxString selectedZone = ''.obs;
  final RxString selectedProject = ''.obs;
  final RxString selectedPackage = ''.obs;
  final RxString selectedStartDate = ''.obs; // YYYY-MM-DD
  final RxString selectedEndDate = ''.obs; // YYYY-MM-DD

  // Temporary for dialog (not applied until "Apply")
  DateTime? tempStartDate;
  DateTime? tempEndDate;

  final Rx<AppColumnDetails> appColumnDetails = AppColumnDetails(
    columns: [],
    frontDisplayColumns: [],
    frontSecondaryDisplayColumns: [],
    buttonDisplayColumn: [],
  ).obs;
  final projectdController = Get.find<ProjectNameDropdownController>();
  final packageController = Get.find<PackageNameController>();
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      projectId.value = args["project_id"] ?? 0;
      packageId.value = args["package_id"] ?? 0;
    }

    log("ACC LIST → projectId=${projectId.value} packageId=${packageId.value}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        // zoneController.fetchZones(context: Get.context!);
        fetchWFUList(reset: true, context: Get.context!);
        projectdController.fetchProjects(context: Get.context!);
        packageController.fetchPackages(context: Get.context!);
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  String _buildQueryParams({bool includePagination = true}) {
    final String proId =
        projectdController.getProjectIdByName(selectedProject.value ?? '') ??
        "";
    final String packageId =
        packageController.getPackageIdByName(selectedPackage.value ?? '') ?? "";
    final parts = <String>[
      'project_id=${proId}',
      'filter_package=${packageId}',
      'priority=${priority.value}',
      'received_date=${''}',
      // 'filter_revised_end_date=${selectedEndDate.value}',
    ];

    if (selectedZone.value.isNotEmpty) {
      parts.add('filter_zone=${Uri.encodeComponent(selectedZone.value)}');
    }

    if (_search.value.isNotEmpty) {
      parts.add('search=${Uri.encodeComponent(_search.value)}');
    }

    parts.add('order_by=${_orderBy.value}');
    parts.add('order_dir=${isAscending.value ? "asc" : "desc"}');

    if (includePagination) {
      parts.add('start=${start.value}');
      parts.add('length=$length');
    }

    return parts.isNotEmpty ? '?${parts.join('&')}' : '';
  }

  Future<void> fetchWFUList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    if (reset) {
      start.value = 0;
      wfuList.clear();
      hasMoreData.value = true;
    }
    if (!hasMoreData.value && !reset) return;
    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';
    try {
      final String query = _buildQueryParams(includePagination: true);
      final String endpoint = Networkutility.getACCList + query;
      final responseList = await Networkcall().getMethod(
        Networkutility.getACCListApi,
        endpoint,
        context,
      );
      final response = responseList?.first as GetAccListResponse?;

      if (response != null && response.status) {
        final data = response.data.data;
        if (frontDisplayColumns.isEmpty) {
          frontDisplayColumns.assignAll(
            response.data.appColumnDetails.frontDisplayColumns,
          );
          buttonDisplayColumns.assignAll(
            response.data.appColumnDetails.buttonDisplayColumn,
          );
          appColumnDetails.value = response.data.appColumnDetails;
        }
        if (data.isEmpty) {
          hasMoreData.value = false;
          if (reset || start.value == 0) {
            _showError('No data available');
          }
        } else {
          if (reset) {
            wfuList.assignAll(data);
          } else {
            wfuList.addAll(data);
          }
          _applyClientFilters();
          start.value += length;

          if (data.length < length) {
            hasMoreData.value = false;
          }
        }
      } else {
        if (reset || start.value == 0) {
          _showError(response?.message ?? 'No data');
        } else {
          hasMoreData.value = false;
        }
      }
    } on NoInternetException catch (e) {
      if (reset || start.value == 0) {
        _showError(e.message);
      }
      hasMoreData.value = false;
    } on TimeoutException catch (e) {
      if (reset || start.value == 0) {
        _showError(e.message);
      }
      hasMoreData.value = false;
    } on HttpException catch (e) {
      if (reset || start.value == 0) {
        _showError('${e.message} (Code: ${e.statusCode})');
      }
      hasMoreData.value = false;
    } on ParseException catch (e) {
      if (reset || start.value == 0) {
        _showError(e.message);
      }
      hasMoreData.value = false;
    } catch (e) {
      if (reset || start.value == 0) {
        _showError('Unexpected error: $e');
      }
      hasMoreData.value = false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> deleteAcc({
    BuildContext? context,
    required String accId,
    required String projectId,
  }) async {
    try {
      isLoadingd.value = true;
      final jsonBody = {"project_id": projectId, "acc_id": accId};

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.deleteAccApi,
        Networkutility.deleteAcc,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetDeleteMeasurmentResponse> response =
            getDeleteMeasurmentResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Deleted',
            message: 'Acc deleted successfully!',
          );
        } else {
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to delete acc.");

          AppSnackbarStyles.showError(
            title: 'Delete Failed',
            message: errorMessage,
          );
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Failed',
          message: "No response from server",
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      Get.back();
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      Get.back();
      AppSnackbarStyles.showError(
        title: 'Unexpected Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoadingd.value = false;
      // Refresh the list after successful deletion
      if (Get.context != null) {
        fetchWFUList(reset: true, context: Get.context!);
      }
    }
  }

  void _showError(String msg) {
    errorMessage.value = msg;
    AppSnackbarStyles.showError(title: 'Error', message: msg);
  }

  Future<void> refreshData() async {
    searchController.clear();
    _search.value = '';
    _orderBy.value = '';
    isAscending.value = true;
    selectedPackageFilter.value = null;
    selectedZone.value = '';
    selectedStartDate.value = '';
    selectedEndDate.value = '';
    tempStartDate = null;
    tempEndDate = null;
    start.value = 0;
    hasMoreData.value = true;
    filteredMeasurementSheets.clear();
    clearFilters();
    await fetchWFUList(reset: true, context: Get.context!);
  }

  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchWFUList(context: context, isPagination: true);
    }
  }

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  List<String> getPackageNames() {
    return wfuList.map((e) => e.getField('Package Name')).toSet().toList();
  }

  String getFieldValue(AccItem item, String columnName) {
    return item.getField(columnName).replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  List<String> getFrontDisplayColumns() {
    return appColumnDetails.value.frontDisplayColumns.toSet().toList();
  }

  List<String> getFrontSecondaryDisplayColumns() {
    return appColumnDetails.value.frontSecondaryDisplayColumns.toSet().toList();
  }

  List<String> getButtonDisplayColumns() {
    return appColumnDetails.value.buttonDisplayColumn.toSet().toList();
  }

  void applyFilters() {
    _applyClientFilters();
  }

  void _applyClientFilters() {
    var list = wfuList.toList();
    if (selectedPackageFilter.value != null &&
        selectedPackageFilter.value!.isNotEmpty) {
      list = list
          .where(
            (e) => e.getField('Package Name') == selectedPackageFilter.value,
          )
          .toList();
    }
    filteredMeasurementSheets.assignAll(list);
  }

  void clearFilters() {
    selectedPackageFilter.value = null;
    selectedProject.value = '';
    selectedPackage.value = '';
    selectedStartDate.value = '';
    selectedEndDate.value = '';
    priority.value = '';
    tempStartDate = null;
    tempEndDate = null;
    searchController.clear();
    _search.value = '';
    fetchWFUList(context: Get.context!, reset: true);
  }

  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _orderBy.value = isAscending.value ? 'desc' : 'asc';
    fetchWFUList(reset: true, context: Get.context!);
  }

  void onPriorityChanged(String? value) {
    priority.value = value ?? '';
  }

  void searchSurveys(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      if (_search.value != trimmed) {
        _search.value = trimmed;
        fetchWFUList(reset: true, context: Get.context!);
      }
    });
  }
}
