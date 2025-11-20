import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_delete_measurement_sheet_response.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_measurmentsheet_response.dart';
import 'package:ashishinterbuild/app/data/models/pboq/pboq_model.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PboqMeasurmentDetailController extends GetxController {
  // ── UI State ─────────────────────────────────────────────────────
  final RxList<AllData> pboqList = <AllData>[].obs;
  final RxList<AllData> filteredPboqList = <AllData>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingd = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  // ── Expand / Collapse ───────────────────────────────────────────
  final RxInt expandedIndex = (-1).obs;
  // ── Search ───────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  // ── Pagination ───────────────────────────────────────────────────
  final RxInt start = 0.obs;
  final int length = 10; // matches API
  // ── API Params ───────────────────────────────────────────────────
  final RxString _search = ''.obs;
  final RxString _orderBy = ''.obs; // asc / desc
  final RxBool isAscending = true.obs;
  // ── Filter (client-side) ────────────────────────────────────────
  final RxnString selectedPackageFilter = RxnString(null);
  final RxString selectedZone = ''.obs;
  final RxString selectedZoneLocation = ''.obs;
  // ── Debounce ─────────────────────────────────────────────────────
  Timer? _debounce;
  // ── Navigation args ─────────────────────────────────────────────
  RxInt projectId = 0.obs;
  RxInt pboqId = 0.obs;
  // ── Column info from API (dynamic labels) ───────────────────────
  final RxList<String> frontDisplayColumns = <String>[].obs;
  final RxList<String> buttonDisplayColumns = <String>[].obs;
  RxInt lengthEnabled = 0.obs;
  RxInt breadthEnabled = 0.obs;
  RxInt heightEnabled = 0.obs;
  RxString uom = "".obs;
  RxString pboqName = "".obs;
  final MeasurementSheetController mesurmentCtrl = Get.put(
    MeasurementSheetController(),
  );
  // ADD: Store full column details
  final Rx<AppColumnDetails> appColumnDetails = AppColumnDetails(
    columns: [],
    frontDisplayColumns: [],
    frontSecondaryDisplayColumns: [],
    buttonDisplayColumn: [],
  ).obs;

  // -----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    // Log all arguments safely
    log("MeasurementSheetController → Received Arguments: ${args ?? 'null'}");

    if (args != null) {
      // Assign values with null safety
      // projectId.value = args["project_id"] ?? 0;
      pboqId.value = args["pboq_id"] ?? 0;
      lengthEnabled.value = args["length"] ?? 0;
      breadthEnabled.value = args["breadth"] ?? 0;
      heightEnabled.value = args["height"] ?? 0;
      uom.value = args["uom"] ?? "";
      pboqName.value = args["pboq_name"] ?? "";

      // Optional: Log individual values for clarity
      log(
        "MeasurementSheetController → "
        "pboq_id: ${pboqId.value}, "
        "uom: ${uom.value}, "
        "length: ${lengthEnabled.value}, "
        "breadth: ${breadthEnabled.value}, "
        "height: ${heightEnabled.value},",
      );
    } else {
      log("MeasurementSheetController → No arguments passed!");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchPboq(reset: true, context: Get.context!);
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // -----------------------------------------------------------------
  // Build query string
  // -----------------------------------------------------------------
  String _buildQueryParams({bool includePagination = true}) {
    final parts = <String>['project_id=', 'pboq_id=$pboqId'];

    if (selectedZone.value.isNotEmpty) {
      parts.add('filter_zone=${Uri.encodeComponent(selectedZone.value)}');
    } else {
      parts.add('filter_zone=');
    }

    if (selectedZoneLocation.value.isNotEmpty) {
      parts.add(
        'filter_zone_location=${Uri.encodeComponent(selectedZoneLocation.value)}',
      );
    } else {
      parts.add('filter_zone_location=');
    }

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

  // -----------------------------------------------------------------
  // Core API call
  // -----------------------------------------------------------------
  Future<void> fetchPboq({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    if (reset) {
      start.value = 0;
      pboqList.clear();
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
      final String endpoint = Networkutility.getPboqMeasurmentSheetList + query;
      final response =
          await Networkcall().getMethod(
                Networkutility.getPboqMeasurmentSheetListApi,
                endpoint,
                context,
              )
              as List<GetPboqMeasurementSheetResponse>?;

      if (response != null && response.isNotEmpty) {
        final api = response.first;
        if (api.status) {
          final data = api.data.data;
          // ---- column info (once) ----
          if (frontDisplayColumns.isEmpty) {
            frontDisplayColumns.assignAll(
              api.data.appColumnDetails.frontDisplayColumns,
            );
            buttonDisplayColumns.assignAll(
              api.data.appColumnDetails.buttonDisplayColumn,
            );
            // ADD: Save full column details
            appColumnDetails.value = api.data.appColumnDetails;
          }
          // ---- pagination guard ----
          if (data.isEmpty) {
            hasMoreData.value = false;
            // If this is the first page and no data, show error
            if (reset || start.value == 0) {
              _showError('No data available');
            }
          } else {
            // ---- map to UI list ----
            final newItems = data;
            if (reset) {
              pboqList.assignAll(newItems);
            } else {
              pboqList.addAll(newItems);
            }
            _applyClientFilters(); // search + package filter
            start.value += length;

            // Check if we have less data than requested (last page)
            if (data.length < length) {
              hasMoreData.value = false;
            }
          }
        } else {
          // Only show error and clear data if this is the first page
          if (reset || start.value == 0) {
            _showError(api.message ?? 'No data');
          } else {
            hasMoreData.value = false;
          }
        }
      } else {
        // Only show error and clear data if this is the first page
        if (reset || start.value == 0) {
          _showError('Empty response');
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

  Future<void> deleteMS({BuildContext? context, required String msId}) async {
    try {
      isLoadingd.value = true;
      final jsonBody = {
        "project_id": mesurmentCtrl.projectId.value,

        "ms_id": msId,
      };

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.deleteMeasurementSheetApi,
        Networkutility.deleteMeasurementSheet,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetDeleteMeasurmentResponse> response =
            getDeleteMeasurmentResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Deleted',
            message: 'PBOQ Measurement Sheet deleted successfully!',
          );
        } else {
          final String errorMessage = response[0].error?.isNotEmpty == true
              ? response[0].error!
              : (response[0].message?.isNotEmpty == true
                    ? response[0].message!
                    : "Failed to delete measurement sheet.");

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
        fetchPboq(reset: true, context: Get.context!);
      }
    }
  }

  void _showError(String msg) {
    errorMessage.value = msg;
    AppSnackbarStyles.showError(title: 'Error', message: msg);
  }

  // -----------------------------------------------------------------
  // Search (debounced) – calls API
  // -----------------------------------------------------------------
  void searchSurveys(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      if (_search.value != trimmed) {
        _search.value = trimmed;
        fetchPboq(reset: true, context: Get.context!);
      }
    });
  }

  // -----------------------------------------------------------------
  // Sort (server-side)
  // -----------------------------------------------------------------
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _orderBy.value = isAscending.value ? 'asc' : 'desc';
    fetchPboq(reset: true, context: Get.context!);
  }

  // -----------------------------------------------------------------
  // Package filter (client-side)
  // -----------------------------------------------------------------
  void applyFilters() {
    _applyClientFilters();
  }

  void _applyClientFilters() {
    var list = pboqList.toList();
    // package filter
    if (selectedPackageFilter.value != null &&
        selectedPackageFilter.value!.isNotEmpty) {
      list = list
          .where((e) => e.packageName == selectedPackageFilter.value)
          .toList();
    }
    filteredPboqList.assignAll(list);
  }

  void clearFilters() {
    selectedPackageFilter.value = null;
    selectedZone.value = '';
    selectedZoneLocation.value = '';
    searchController.clear();
    _search.value = '';
    fetchPboq(reset: true, context: Get.context!);
  }

  // -----------------------------------------------------------------
  // Pagination – load more
  // -----------------------------------------------------------------
  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchPboq(context: context, isPagination: true);
    }
  }

  // -----------------------------------------------------------------
  // Pull-to-refresh
  // -----------------------------------------------------------------
  Future<void> refreshData() async {
    searchController.clear();
    _search.value = '';
    _orderBy.value = '';
    isAscending.value = true;
    selectedPackageFilter.value = null;
    selectedZone.value = '';
    selectedZoneLocation.value = '';
    start.value = 0;
    hasMoreData.value = true;
    filteredPboqList.clear();

    await fetchPboq(reset: true, context: Get.context!);
  }

  // -----------------------------------------------------------------
  // Helper – unique package names for dropdown
  // -----------------------------------------------------------------
  List<String> getPackageNames() {
    return pboqList.map((e) => e.packageName).toSet().toList();
  }

  // -----------------------------------------------------------------
  // Dynamic field helpers
  // -----------------------------------------------------------------
  String _stripHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  String getFieldValue(AllData item, String columnName) {
    return _stripHtmlTags(item.getField(columnName));
  }

  List<String> getAllColumns() {
    final allCols = appColumnDetails.value.columns.toSet();
    final frontCols = appColumnDetails.value.frontDisplayColumns.toSet();
    final frontSecondaryCols = appColumnDetails
        .value
        .frontSecondaryDisplayColumns
        .toSet();
    final buttonCols = appColumnDetails.value.buttonDisplayColumn.toSet();

    return allCols
        .difference(frontCols)
        .difference(frontSecondaryCols)
        .difference(buttonCols)
        .toList();
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

  // -----------------------------------------------------------------
  // UI actions
  // -----------------------------------------------------------------
  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
    log("expand trgger");
  }

  void viewMeasurementSheet(AllData item) {
    log('View PBOQ: ${item.pboqName} (ID: ${item.pboqId})');
    // TODO: navigate to detail page with required params
  }
}
