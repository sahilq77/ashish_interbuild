import 'dart:async';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/daily_progress_report/daily_progress_report_model.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/update_daily_progress_report_model.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UpdateProgressReportController extends GetxController {
  final DailyProgressReportController dprController = Get.find();
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
  RxString sourceName = "".obs;
  RxString systemId = "".obs;
  final RxList<String> frontDisplayColumns = <String>[].obs;
  final RxList<String> buttonDisplayColumns = <String>[].obs;
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
      sourceName.value = args["selected_source"] ?? "";
      systemId.value = args["selected_system_id"] ?? "";
    }

    // Set default values if still 0

    log("DPR Detail → Source=${sourceName.value} System Id=${systemId.value}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
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
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final parts = <String>[
      'project_id=${dprController.projectId}',
      'filter_package=${dprController.packageId}',
      'selected_source=${sourceName.value}',
      'selected_system_id=${systemId.value}',
      'filter_revised_start_date=${today}',
      'filter_revised_finish_date =${today}',
    ];
    if (_search.value.isNotEmpty) {
      parts.add('search=${Uri.encodeComponent(_search.value)}');
    }
    parts.add('order_by=${_orderBy.value}');
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
      final String endpoint = Networkutility.getDprReportDetailList + query;
      final responseList = await Networkcall().getMethod(
        Networkutility.getDprReportDetailListApi,
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
        if (data.isEmpty || data.length < length) hasMoreData.value = false;
        if (reset) {
          dprList.assignAll(data);
        } else {
          dprList.addAll(data);
        }
        _applyClientFilters();
        start.value += length;
      } else {
        _showError(response?.message ?? 'No data');
      }
    } on NoInternetException catch (e) {
      _showError(e.message);
    } on TimeoutException catch (e) {
      _showError(e.message);
    } on HttpException catch (e) {
      _showError('${e.message} (Code: ${e.statusCode})');
    } on ParseException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unexpected error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _showError(String msg) {
    hasMoreData.value = false;
    errorMessage.value = msg;
    AppSnackbarStyles.showError(title: 'Error', message: msg);
  }

  Future<void> refreshData() async {
    searchController.clear();
    _search.value = '';
    _orderBy.value = '';
    isAscending.value = true;
    selectedPackageFilter.value = null;
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

  // Function to toggle the expanded state of a card
  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Collapse if the same card is clicked
    } else {
      expandedIndex.value = index; // Expand the clicked card
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
    searchController.clear();
    _search.value = '';
    _applyClientFilters();
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
