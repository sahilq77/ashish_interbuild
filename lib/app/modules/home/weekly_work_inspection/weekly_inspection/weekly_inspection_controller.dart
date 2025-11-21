import 'dart:async';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/daily_progress_report/daily_progress_report_model.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/measurment_sheet_model.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/weekly_period/weekly_period_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WeeklyInspectionController extends GetxController {
  final zoneController = Get.find<ZoneController>();
  final WeeklyPeriodController weeklypController = Get.find();
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
  // Dynamic week date filters
  RxString filterInspectionFromDate = ''.obs;
  RxString filterInspectionToDate = ''.obs;

  // Year dropdown
  RxString selectedYear = ''.obs;
  RxList<String> yearList = <String>[].obs;

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

    log(
      "Weekly Inspection → projectId=${projectId.value} packageId=${packageId.value}",
    );
    _setCurrentWeekDates();
    _generateYearList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        zoneController.fetchZones(context: Get.context!);
        weeklypController.fetchPeriods(context: Get.context!);
        _autoSelectCurrentWeek();
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

  void _setCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    filterInspectionFromDate.value = DateFormat(
      'yyyy-MM-dd',
    ).format(startOfWeek);
    filterInspectionToDate.value = DateFormat('yyyy-MM-dd').format(endOfWeek);
  }

  void _generateYearList() {
    final currentYear = DateTime.now().year;
    yearList.clear();
    for (int i = 0; i < 5; i++) {
      yearList.add((currentYear - i).toString());
    }
    selectedYear.value = currentYear.toString();
  }

  void _autoSelectCurrentWeek() {
    final today = DateTime.now();
    final periods = weeklypController.periodsList;

    for (var period in periods) {
      if (today.isAfter(
            period.weekFromDate.subtract(const Duration(days: 1)),
          ) &&
          today.isBefore(period.weekToDate.add(const Duration(days: 1)))) {
        weeklypController.selectedPeriodVal.value = period.label;
        filterInspectionFromDate.value = DateFormat(
          'yyyy-MM-dd',
        ).format(period.weekFromDate);
        filterInspectionToDate.value = DateFormat(
          'yyyy-MM-dd',
        ).format(period.weekToDate);
        break;
      }
    }
  }

  String _buildQueryParams({bool includePagination = true}) {
    final parts = <String>[
      'project_id=${projectId.value}',
      'filter_package=${packageId.value == 0 ? "" : packageId.value}',
      'filter_inspection_from_date=${filterInspectionFromDate.value}',
      'filter_inspection_to_date=${filterInspectionToDate.value}',
    ];

    if (selectedZone.value.isNotEmpty) {
      parts.add('filter_zone=${Uri.encodeComponent(selectedZone.value)}');
    }

    if (_search.value.isNotEmpty) {
      parts.add('search=${Uri.encodeComponent(_search.value)}');
    }

    parts.add('order_by=${_orderBy.value}');
    // parts.add('order_dir=${isAscending.value ? "desc" : "asc"}');

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
      final String endpoint = Networkutility.getWIRList + query;
      final responseList = await Networkcall().getMethod(
        Networkutility.getWIRListApi,
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
    selectedZone.value = '';
    selectedStartDate.value = '';
    selectedEndDate.value = '';
    tempStartDate = null;
    tempEndDate = null;
    start.value = 0;
    hasMoreData.value = true;
    filteredMeasurementSheets.clear();
    _setCurrentWeekDates();
    _generateYearList();
    _autoSelectCurrentWeek();
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
