import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_dpr_list_response.dart'
    hide DprItem, AppColumnDetails;
import 'package:ashishinterbuild/app/data/models/daily_progress_report/get_update_dpr_list_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
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
  final DailyProgressReportController dprController = Get.put(
    DailyProgressReportController(),
  );

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
  RxString uom = "".obs;
  final RxList<String> frontDisplayColumns = <String>[].obs;
  final RxList<String> buttonDisplayColumns = <String>[].obs;
  final RxList<DprCounts> dprCount = <DprCounts>[].obs;

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
  final RxString selectedPboq = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  RxString packageName = "".obs;
  RxString pboqName = "".obs;

  // Multi-select and multi-image functionality
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedIndices = <int>{}.obs;
  final RxMap<int, List<XFile>> rowImages = <int, List<XFile>>{}.obs;
  final ImagePicker _picker = ImagePicker();

  // @override
  // void onInit() {
  //   super.onInit();
  //   final args = Get.arguments as Map<String, dynamic>?;
  //   if (args != null) {
  //     sourceName.value = args["selected_source"] ?? "";
  //     systemId.value = args["selected_system_id"] ?? "";
  //   }

  //   // Set default values if still 0

  //   log("DPR Detail → Source=${sourceName.value} System Id=${systemId.value}");
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (Get.context != null) {
  //       fetchDprList(reset: true, context: Get.context!);
  //       // zoneController.fetchZones(context: Get.context!);
  //       // zoneLocationController.fetchZoneLocations(context: Get.context!);
  //     }
  //   });
  // }

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
      'project_id=${dprController.projectId.value}',
      'filter_package=${dprController.packageId.value == 0 ? "" : dprController.packageId.value}',
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
    if (selectedPboq.value.isNotEmpty) {
      parts.add('filter_pboq=${Uri.encodeComponent(selectedPboq.value)}');
    } else {
      parts.add('filter_pboq=');
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
      final response = responseList?.first as GetUpdateDPRListResponse?;

      if (response != null && response.status) {
        final data = response.data.data;
        dprCount.add(
          DprCounts(
            projectId: response.data.dprCounts!.projectId,
            packageId: response.data.dprCounts!.packageId,
            pboqId: response.data.dprCounts!.pboqId,
            totalMs: response.data.dprCounts!.totalMs,
            dprStatus: response.data.dprCounts!.dprStatus,
          ),
        );
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
    start.value = 0;
    hasMoreData.value = true;
    filteredMeasurementSheets.clear();
    toggleMultiSelectMode();
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
    selectedPboq.value = "";
    selectedDate.value = null;
    searchController.clear();
    _search.value = '';
    fetchDprList(context: Get.context!, reset: true);
  }

  void toggleMultiSelectMode() {
    isMultiSelectMode.value = !isMultiSelectMode.value;
    if (!isMultiSelectMode.value) {
      selectedIndices.clear();
    }
  }

  void startMultiSelect(int index) {
    isMultiSelectMode.value = true;
    selectedIndices.add(index);
  }

  void toggleItemSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }

  Future<void> pickImageForRow(int index) async {
    try {
      showModalBottomSheet(
        context: Get.context!,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to pick image: $e',
      );
    }
  }

  Future<void> _pickImages(int index, ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          if (rowImages[index] == null) {
            rowImages[index] = [];
          }
          rowImages[index]!.add(image);
          rowImages.refresh();
        }
      } else {
        final List<XFile> images = await _picker.pickMultiImage() ?? [];
        if (images.isNotEmpty) {
          if (rowImages[index] == null) {
            rowImages[index] = [];
          }
          rowImages[index]!.addAll(images);
          rowImages.refresh();
        }
      }
    } catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to pick images: $e',
      );
    }
  }

  void removeImageFromRow(int index, int imageIndex) {
    if (rowImages[index] != null && imageIndex < rowImages[index]!.length) {
      rowImages[index]!.removeAt(imageIndex);
      if (rowImages[index]!.isEmpty) {
        rowImages.remove(index);
      }
      rowImages.refresh();
    }
  }

  Future<void> batchUpdateSelectedDPRs() async {
    if (selectedIndices.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please select items to update',
      );
      return;
    }

    isLoadingu.value = true;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.updateDailyProgressReport),
      );

      // Add auth header
      if (AppUtility.authToken != null && AppUtility.authToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${AppUtility.authToken}';
      }

      // Build rows and files
      for (int i = 0; i < selectedIndices.length; i++) {
        final int rowIndex = selectedIndices.elementAt(i); // Actual index in l
        final item = filteredMeasurementSheets[rowIndex];

        final msId = item.getField('measurement_sheet_id')?.toString() ?? '0';

        // Text fields for this row
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

        // Add multiple images for this row → goes into one array: attachments[]
        if (rowImages[rowIndex] != null && rowImages[rowIndex]!.isNotEmpty) {
          for (int j = 0; j < rowImages[rowIndex]!.length; j++) {
            final XFile imageFile = rowImages[rowIndex]![j];

            final multipartFile = await http.MultipartFile.fromPath(
              'ms_rows[$i][attachments][]', // EXACT MATCH with Postman
              imageFile.path,
              filename: path.basename(imageFile.path),
            );

            request.files.add(multipartFile);
          }
        }
      }

      // === DEBUG: Log full request ===
      log('=== MULTIPART REQUEST ===');
      request.fields.forEach((k, v) => log('Field → $k: $v'));
      for (var file in request.files) {
        log('File → ${file.field}: ${file.filename} (${file.length} bytes)');
      }
      log('========================');

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      log('Response ($streamedResponse.statusCode): $responseBody');

      if (streamedResponse.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['status'] == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: jsonResponse['message'] ?? 'DPR updated successfully',
          );

          // Reset UI
          selectedIndices.clear();
          rowImages.clear();
          isMultiSelectMode.value = false;
          await fetchDprList(reset: true, context: Get.context!);
        } else {
          AppSnackbarStyles.showError(
            title: 'Failed',
            message: jsonResponse['message'] ?? 'Update failed',
          );
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Server Error',
          message: 'HTTP ${streamedResponse.statusCode}',
        );
      }
    } catch (e, s) {
      log('Update DPR Exception: $e\n$s');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to update: $e',
      );
    } finally {
      isLoadingu.value = false;
    }
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
