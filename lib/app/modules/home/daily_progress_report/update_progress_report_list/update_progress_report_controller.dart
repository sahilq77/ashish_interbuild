import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';

import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // ← THIS IS THE CORRECT ONE
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer; // Make sure this is imported
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

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
  final errorMessageu = ''.obs;
  final successMessage = ''.obs;
  final RxBool isLoadingu = false.obs;

  final RxString selectedZone = ''.obs;
  final RxString selectedZoneLocation = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

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
    final String dateFilter = selectedDate.value != null 
        ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    final parts = <String>[
      'project_id=${dprController.projectId}',
      'filter_package=${dprController.packageId}',
      'selected_source=${sourceName.value}',
      'selected_system_id=${systemId.value}',
      'filter_revised_start_date=${dateFilter}',
      'filter_revised_finish_date =${dateFilter}',
    ];
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
    selectedZone.value = "";
    selectedZoneLocation.value = "";
    selectedDate.value = null;
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

  // Multi-select & Image Picker
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedIndices = <int>{}.obs;
  final RxMap<int, List<XFile>> rowImages = <int, List<XFile>>{}.obs;
  final ImagePicker _picker = ImagePicker();

  void toggleMultiSelectMode() {
    isMultiSelectMode.value = !isMultiSelectMode.value;
    if (!isMultiSelectMode.value) {
      selectedIndices.clear();
    }
  }

  void toggleItemSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }

  Future<void> pickImagesForRow(int rowIndex) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        rowImages[rowIndex] = images;
      }
    } catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to pick images: $e',
      );
    }
  }

  void removeImageFromRow(int rowIndex, int imageIndex) {
    if (rowImages.containsKey(rowIndex) &&
        imageIndex < rowImages[rowIndex]!.length) {
      rowImages[rowIndex]!.removeAt(imageIndex);
      if (rowImages[rowIndex]!.isEmpty) {
        rowImages.remove(rowIndex);
      }
    }
  }

  Future<void> updateSelectedDPR(BuildContext context) async {
    if (selectedIndices.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please select at least one item to update',
      );
      return;
    }

    isLoadingu.value = true;
    errorMessageu.value = '';
    successMessage.value = '';

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.updateDailyProgressReport),
      );

      // Add form fields
      request.fields['project_id'] = dprController.projectId.toString();
      request.fields['system_id'] = systemId.value
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();
      request.fields['source_table'] = sourceName.value;

      // Add each selected row
      int i = 0;
      for (int idx in selectedIndices) {
        final item = filteredMeasurementSheets[idx];
        final msId = item.getField('measurement_sheet_id') ?? '0';

        request.fields['ms_rows[$i][project_id]'] = dprController.projectId
            .toString();
        request.fields['ms_rows[$i][system_id]'] = systemId.value
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();
        request.fields['ms_rows[$i][source_table]'] = sourceName.value;
        request.fields['ms_rows[$i][measurement_sheet_id]'] = msId;
        request.fields['ms_rows[$i][progress_status]'] = '1';
        request.fields['ms_rows[$i][dpr_date]'] = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
        request.fields['ms_rows[$i][executed_qty]'] =
            item.getField('executed_qty') ?? '0';

        // Add images for this row
        if (rowImages.containsKey(idx)) {
          for (
            int imgIndex = 0;
            imgIndex < rowImages[idx]!.length;
            imgIndex++
          ) {
            final image = rowImages[idx]![imgIndex];
            final multipartFile = await http.MultipartFile.fromPath(
              'ms_rows[$i][attachment][$imgIndex]',
              image.path,
            );
            request.files.add(multipartFile);
          }
        }
        i++;
      }

      // ==================== DETAILED REQUEST LOGGING ====================
      final logBuffer = StringBuffer();
      logBuffer.writeln('=== DPR UPDATE REQUEST ===');
      logBuffer.writeln('URL: ${request.url}');
      logBuffer.writeln('Method: ${request.method}');
      logBuffer.writeln('\n--- Form Fields ---');
      request.fields.forEach((key, value) {
        logBuffer.writeln('$key: $value');
      });

      logBuffer.writeln('\n--- Attached Files ---');
      if (request.files.isEmpty) {
        logBuffer.writeln('No files attached');
      } else {
        for (var file in request.files) {
          logBuffer.writeln(
            '${file.field}: ${file.filename} (${file.length} bytes)',
          );
        }
      }
      logBuffer.writeln('Total files: ${request.files.length}');
      logBuffer.writeln('==========================');

      // Use developer.log (supports long strings, won't truncate like print())
      developer.log(
        logBuffer.toString(),
        name: 'DPR_UPDATE_REQUEST',
        level: 800, // INFO level
      );
      // ==================================================================

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Response logging
      developer.log(
        'DPR Update Response: ${response.statusCode}\n$responseBody',
        name: 'DPR_UPDATE_RESPONSE',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        successMessage.value = 'DPR updated successfully';
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: 'DPR updated successfully',
        );

        selectedIndices.clear();
        rowImages.clear();
        isMultiSelectMode.value = false;
        await refreshData();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error updating DPR',
        name: 'DPR_UPDATE_ERROR',
        error: e,
        stackTrace: stackTrace,
      );
      errorMessageu.value = 'Failed to update DPR: $e';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to update DPR. Please try again.',
      );
    } finally {
      isLoadingu.value = false;
    }
  }

  // Toggle item selection
  void toggleSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
    if (selectedIndices.isEmpty) {
      isMultiSelectMode.value = false;
    }
  }

  // Start multi-select on long press
  void startMultiSelect(int index) {
    if (!isMultiSelectMode.value) {
      isMultiSelectMode.value = true;
    }
    toggleSelection(index);
  }

  // Clear all selections
  void clearSelection() {
    selectedIndices.clear();
    isMultiSelectMode.value = false;
    rowImages.clear();
  }

  // Get total selected images count
  int getTotalImagesCount() {
    return rowImages.values.fold(0, (sum, images) => sum + images.length);
  }

  // Remove image
  // void removeImage(int index) {
  //   selectedImages.removeAt(index);
  // }

  /// ADD THIS HELPER METHOD IN YOUR CLASS (GetX Controller or wherever you have this function)
  void _logMultipartRequest(http.MultipartRequest request) {
    developer.log(
      '╔════════════════════════════════════════════════════════════',
      name: 'DPR_Update',
    );
    developer.log(
      '║              BATCH DPR UPDATE REQUEST LOG                 ',
      name: 'DPR_Update',
    );
    developer.log(
      '╠════════════════════════════════════════════════════════════',
      name: 'DPR_Update',
    );
    developer.log(
      '║ URL: ${request.method} ${request.url}',
      name: 'DPR_Update',
    );
    developer.log('║ Headers:', name: 'DPR_Update');
    request.headers.forEach((key, value) {
      final display = key.toLowerCase().contains('authorization')
          ? 'Bearer ***'
          : value;
      developer.log('║   $key: $display', name: 'DPR_Update');
    });

    developer.log('║', name: 'DPR_Update');
    developer.log('║ FIELDS (${request.fields.length}):', name: 'DPR_Update');
    request.fields.forEach((key, value) {
      final displayValue = value.length > 300
          ? '${value.substring(0, 300)}...'
          : value;
      developer.log('║   $key: $displayValue', name: 'DPR_Update');
    });

    developer.log('║', name: 'DPR_Update');
    developer.log('║ FILES (${request.files.length}):', name: 'DPR_Update');
    for (int i = 0; i < request.files.length; i++) {
      final file = request.files[i];
      final filename = file.filename ?? 'unknown';
      final size = file.length > 0 ? _formatBytes(file.length) : 'unknown size';
      developer.log(
        '║   [${file.field}] $filename → $size',
        name: 'DPR_Update',
      );
    }

    developer.log(
      '╚════════════════════════════════════════════════════════════',
      name: 'DPR_Update',
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// YOUR MAIN FUNCTION — FULLY UPDATED WITH LOGGING
  Future<void> batchUpdateSelectedDPRs() async {
    if (selectedIndices.isEmpty) {
      AppSnackbarStyles.showError(
        title: "Error",
        message: "Please select at least one item",
      );
      return;
    }

    isLoadingu.value = true;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.updateDailyProgressReport),
      );

      // Common fields

      // Add each selected row
      int i = 0;
      for (int idx in selectedIndices) {
        final item = filteredMeasurementSheets[idx];

        final msId = item.getField('measurement_sheet_id')?.toString() ?? '0';
        final msQty = item.getField('MS QTY')?.toString() ?? '0';

        request.fields['ms_rows[$i][project_id]'] = dprController.projectId
            .toString();
        request.fields['ms_rows[$i][system_id]'] = systemId.value
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();
        request.fields['ms_rows[$i][source_table]'] = sourceName.value;
        request.fields['ms_rows[$i][measurement_sheet_id]'] = msId;
        request.fields['ms_rows[$i][progress_status]'] = '1';
        request.fields['ms_rows[$i][dpr_date]'] = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
        request.fields['ms_rows[$i][executed_qty]'] =
            item.getField('MS QTY')?.toString() ?? '0';

        // Attach images for this specific row (if any)
        if (rowImages.containsKey(idx) && rowImages[idx]!.isNotEmpty) {
          for (
            int imgIndex = 0;
            imgIndex < rowImages[idx]!.length;
            imgIndex++
          ) {
            final image = rowImages[idx]![imgIndex];
            final file = File(image.path);
            if (await file.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'ms_rows[$i][attachment]',
                  image.path,
                  filename: path.basename(image.path),
                ),
              );
            }
          }
        }
        i++;
      }

      if (i == 0) {
        throw Exception("No valid measurement sheets selected");
      }

      // Authorization header
      if (AppUtility.authToken != null && AppUtility.authToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${AppUtility.authToken}';
      }

      // LOG THE ENTIRE REQUEST (THIS IS WHAT YOU WANTED)
      _logMultipartRequest(request);

      developer.log(
        "Sending batch update with $i rows and ${request.files.length} attachments...",
        name: 'DPR_Update',
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log(
        "Response: ${response.statusCode} ${response.body}",
        name: 'DPR_Update',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbarStyles.showSuccess(
          title: "Success",
          message: "DPR Updated Successfully!",
        );
        clearSelection();
        rowImages.clear();
        await refreshData();
      } else {
        throw Exception(
          "Server error: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        "Error in batchUpdateSelectedDPRs: $e",
        name: 'DPR_Update',
        error: e,
        stackTrace: stackTrace,
      );
      AppSnackbarStyles.showError(
        title: "Update Failed",
        message: e.toString().length > 100
            ? "Failed to update DPR. Check logs."
            : e.toString(),
      );
    } finally {
      isLoadingu.value = false;
    }
  }
}
