import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ashishinterbuild/app/data/models/weekly_inspection/get_weekly_inspection_update_list_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_controller.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class UpdateWeeklyInspectionController extends GetxController {
  final WeeklyInspectionController wiController = Get.put(
    WeeklyInspectionController(),
  );

  final RxList<WIRItem> wirList = <WIRItem>[].obs;
  final RxList<WIRItem> filteredWirItems = <WIRItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingu = false.obs;
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

  final Rx<AppColumnDetails> appColumnDetails = AppColumnDetails(
    columns: [],
    frontDisplayColumns: [],
    frontSecondaryDisplayColumns: [],
    buttonDisplayColumn: [],
  ).obs;

  final RxString selectedZone = ''.obs;
  final RxString selectedZoneLocation = ''.obs;
  final RxString selectedPboq = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  RxString packageName = "".obs;
  RxString pboqName = "".obs;

  // Multi-select & multi-image
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedIndices = <int>{}.obs;
  final RxMap<int, List<XFile>> rowImages = <int, List<XFile>>{}.obs;
  final ImagePicker _picker = ImagePicker();

  RxString startDate = "".obs;
  RxString endDate = "".obs;

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
      'project_id=${wiController.projectId.value}',
      'filter_package=${wiController.packageId.value == 0 ? "" : wiController.packageId.value}',
      'selected_source=${sourceName.value}',
      'selected_system_id=${systemId.value}',
      'filter_inspection_from_date=${'2025-11-24'}',
      'filter_inspection_to_date=${'2025-11-30'}',
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

  Future<void> fetchWirList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    if (reset) {
      start.value = 0;
      wirList.clear();
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
      final String endpoint = Networkutility.getWirDetailList + query;

      final responseList = await Networkcall().getMethod(
        Networkutility.getWirDetailListApi,
        endpoint,
        context,
      );

      final response =
          responseList?.first as GetUpdateWeeklyInspectionListResponse?;

      if (response != null && response.status == true) {
        // FIXED: Correctly get the list of items
        final List<WIRItem> items = response.data.data;
        log("Items $items");
        if (frontDisplayColumns.isEmpty) {
          frontDisplayColumns.assignAll(
            response.data.appColumnDetails.frontDisplayColumns,
          );
          buttonDisplayColumns.assignAll(
            response.data.appColumnDetails.buttonDisplayColumn,
          );
          appColumnDetails.value = response.data.appColumnDetails;
        }

        if (items.isEmpty) {
          hasMoreData.value = false;
          if (reset || start.value == 0) _showError('No WIR data available');
        } else {
          if (reset) {
            wirList.assignAll(items);
          } else {
            wirList.addAll(items);
          }
          _applyClientFilters();
          start.value += length;
          if (items.length < length) hasMoreData.value = false;
        }
      } else {
        if (reset || start.value == 0) {
          _showError(response?.message ?? 'No data found');
        } else {
          hasMoreData.value = false;
        }
      }
    } on NoInternetException catch (e) {
      _showError(e.message);
      hasMoreData.value = false;
    } on TimeoutException catch (e) {
      _showError(e.message);
      hasMoreData.value = false;
    } on HttpException catch (e) {
      _showError('${e.message} (Code: ${e.statusCode})');
      hasMoreData.value = false;
    } on ParseException catch (e) {
      _showError(e.message);
      hasMoreData.value = false;
    } catch (e) {
      _showError('Unexpected error: $e');
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
    selectedZoneLocation.value = '';
    selectedPboq.value = '';
    selectedDate.value = null;

    start.value = 0;
    hasMoreData.value = true;
    filteredWirItems.clear();
    toggleMultiSelectMode(off: true);
    await fetchWirList(reset: true, context: Get.context!);
  }

  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchWirList(context: context, isPagination: true);
    }
  }

  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  List<String> getPackageNames() {
    return wirList.map((e) => e.getField('Package Name')).toSet().toList();
  }

  String getFieldValue(WIRItem item, String columnName) {
    return item.getField(columnName).replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  List<String> getFrontDisplayColumns() =>
      appColumnDetails.value.frontDisplayColumns;
  List<String> getFrontSecondaryDisplayColumns() =>
      appColumnDetails.value.frontSecondaryDisplayColumns;
  List<String> getButtonDisplayColumns() =>
      appColumnDetails.value.buttonDisplayColumn;

  void _applyClientFilters() {
    var list = wirList.toList();

    if (selectedPackageFilter.value != null &&
        selectedPackageFilter.value!.isNotEmpty) {
      list = list
          .where(
            (e) => e.getField('Package Name') == selectedPackageFilter.value,
          )
          .toList();
    }

    filteredWirItems.assignAll(list);
  }

  void applyFilters() => _applyClientFilters();

  void clearFilters() {
    selectedPackageFilter.value = null;
    selectedZone.value = "";
    selectedZoneLocation.value = "";
    selectedPboq.value = "";
    selectedDate.value = null;
    searchController.clear();
    _search.value = '';
    fetchWirList(context: Get.context!, reset: true);
  }

  void toggleMultiSelectMode({bool off = false}) {
    isMultiSelectMode.value = off ? false : !isMultiSelectMode.value;
    if (!isMultiSelectMode.value) {
      selectedIndices.clear();
      rowImages.clear();
    }
  }

  void startMultiSelect(int index) {
    isMultiSelectMode.value = true;
    selectedIndices.add(index);
  }

  void toggleItemSelection(int index) {
    selectedIndices.contains(index)
        ? selectedIndices.remove(index)
        : selectedIndices.add(index);
  }

  Future<void> pickImageForRow(int index) async {
    showModalBottomSheet(
      context: Get.context!,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(Get.context!);
                _pickImages(index, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(Get.context!);
                _pickImages(index, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages(int index, ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          rowImages.putIfAbsent(index, () => []);
          rowImages[index]!.add(image);
          rowImages.refresh();
        }
      } else {
        final images = await _picker.pickMultiImage();
        if (images != null && images.isNotEmpty) {
          rowImages.putIfAbsent(index, () => []);
          rowImages[index]!.addAll(images);
          rowImages.refresh();
        }
      }
    } catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to pick image: $e',
      );
    }
  }

  void removeImageFromRow(int rowIndex, int imageIndex) {
    final images = rowImages[rowIndex];
    if (images != null && imageIndex < images.length) {
      images.removeAt(imageIndex);
      if (images.isEmpty) rowImages.remove(rowIndex);
      rowImages.refresh();
    }
  }

  Future<void> batchUpdateSelectedWIRs() async {
    if (selectedIndices.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Please select at least one item',
      );
      return;
    }

    isLoadingu.value = true;
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.updateWIR),
      );

      // Add auth header
      if (AppUtility.authToken?.isNotEmpty == true) {
        request.headers['Authorization'] = 'Bearer ${AppUtility.authToken}';
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final weekNo = getWeekNumber(now).toString(); // You'll need this helper
      final year = now.year.toString();

      for (int i = 0; i < selectedIndices.length; i++) {
        final index = selectedIndices.elementAt(i);
        final item = filteredWirItems[index];

        final msId = item.getField('measurement_sheet_id')?.toString() ?? '0';
        final executedQty = item.getField('MS QTY')?.toString() ?? '0';

        // Ensure systemId is clean integer!
        final cleanSystemId = systemId.value
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim()
            .replaceAll(RegExp(r'[^0-9]'), ''); // Extra safety

        request.fields['ms_rows[$i][project_id]'] = wiController.projectId
            .toString();
        request.fields['ms_rows[$i][measurement_sheet_id]'] = msId;
        request.fields['ms_rows[$i][progress_status]'] = '1';
        request.fields['ms_rows[$i][pending_status]'] =
            '0'; // or appropriate value
        request.fields['ms_rows[$i][executed_qty]'] = executedQty;
        request.fields['ms_rows[$i][dpr_pending_qty]'] =
            '0'; // adjust logic if needed

        request.fields['ms_rows[$i][dpr_date]'] = formattedDate;
        request.fields['ms_rows[$i][dpr_from_date]'] = formattedDate;
        request.fields['ms_rows[$i][dpr_to_date]'] = formattedDate;

        // Optional: inspection dates (set if needed)
        // request.fields['ms_rows[$i][inspection_from_date]'] = formattedDate;
        // request.fields['ms_rows[$i][inspection_to_date]'] = formattedDate;

        request.fields['ms_rows[$i][week_no]'] = weekNo;
        request.fields['ms_rows[$i][year]'] = year;
        request.fields['ms_rows[$i][system_id]'] = cleanSystemId;
        request.fields['ms_rows[$i][source_table]'] = sourceName.value;

        // Handle file attachments per row
        if (rowImages[index] != null && rowImages[index]!.isNotEmpty) {
          for (int j = 0; j < rowImages[index]!.length; j++) {
            final file = rowImages[index]![j];
            final multipartFile = await http.MultipartFile.fromPath(
              'ms_rows[$i][attachment][]', // Correct syntax for array of files per row
              file.path,
              filename: path.basename(file.path),
            );
            request.files.add(multipartFile);
          }
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      log('Batch WIR Update Response: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['status'] == true) {
          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message:
                jsonResponse['message'] ??
                'Weekly Inspection updated successfully',
          );

          selectedIndices.clear();
          rowImages.clear();
          toggleMultiSelectMode(off: true);
          await fetchWirList(reset: true, context: Get.context!);
        } else {
          AppSnackbarStyles.showError(
            title: 'Failed',
            message: jsonResponse['message'] ?? 'Update failed',
          );
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Server Error',
          message: 'Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('WIR Batch Update Error: $e');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to update: $e',
      );
    } finally {
      isLoadingu.value = false;
    }
  }

  // Helper: Get ISO week number
  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = _weeksInYear(date.year - 1);
    } else if (woy > _weeksInYear(date.year)) {
      woy = 1;
    }
    return woy;
  }

  int _weeksInYear(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _orderBy.value = isAscending.value ? 'asc' : 'desc';
    fetchWirList(reset: true, context: Get.context!);
  }

  void searchWirItems(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      if (_search.value != trimmed) {
        _search.value = trimmed;
        fetchWirList(reset: true, context: Get.context!);
      }
    });
  }
}
