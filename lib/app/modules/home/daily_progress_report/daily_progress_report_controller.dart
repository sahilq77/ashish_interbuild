import 'dart:async';
import 'dart:developer';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DailyProgressReportController extends GetxController {
  final zoneController = Get.find<ZoneController>();
  final RxList<DprItem> dprList = <DprItem>[].obs;
  final RxList<DprItem> filteredMeasurementSheets = <DprItem>[].obs;
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

  // FILTERS
  final RxString selectedZone = ''.obs;
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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      projectId.value = args["project_id"] ?? 0;
      packageId.value = args["package_id"] ?? 0;
    }

    log("DPR → projectId=${projectId.value} packageId=${packageId.value}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        zoneController.fetchZones(context: Get.context!);
        fetchDprList(reset: true, context: Get.context!);
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
    final parts = <String>[
      'project_id=${projectId.value}',
      'filter_package=${packageId.value == 0 ? "" : packageId.value}',
      'filter_revised_start_date=${selectedStartDate.value}',
      'filter_revised_finish_date=${selectedEndDate.value}',
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

  Future<void> fetchDprList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    if (reset) {
      start.value = 0;
      dprList.clear();
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
      final String endpoint = Networkutility.getDPRList + query;
      final responseList = await Networkcall().getMethod(
        Networkutility.getDPRListApi,
        endpoint,
        context,
      );
      final response = responseList?.first as GetDprListResponse?;

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
            dprList.assignAll(data);
          } else {
            dprList.addAll(data);
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
    await fetchDprList(reset: true, context: Get.context!);
  }

  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchDprList(context: context, isPagination: true);
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
    return dprList.map((e) => e.getField('Package Name')).toSet().toList();
  }

  String getFieldValue(DprItem item, String columnName) {
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
    var list = dprList.toList();
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
    selectedZone.value = '';
    selectedStartDate.value = '';
    selectedEndDate.value = '';
    tempStartDate = null;
    tempEndDate = null;
    searchController.clear();
    _search.value = '';
    fetchDprList(context: Get.context!, reset: true);
  }

  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _orderBy.value = isAscending.value ? 'desc' : 'asc';
    fetchDprList(reset: true, context: Get.context!);
  }

  void searchSurveys(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      if (_search.value != trimmed) {
        _search.value = trimmed;
        fetchDprList(reset: true, context: Get.context!);
      }
    });
  }
}
