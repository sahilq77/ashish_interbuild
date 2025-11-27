import 'dart:async';
import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/global_model/packages/get_package_name_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart'
    show AppSnackbarStyles;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PackageListController extends GetxController {
  // ── UI State ─────────────────────────────────────────────────────
  final RxList<PackageData> packages =
      <PackageData>[].obs; // internal full list
  final RxList<PackageData> filteredPackages =
      <PackageData>[].obs; // shown in UI
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // ── Pagination ───────────────────────────────────────────────────
  final RxInt offset = 0.obs;
  final int limit = 20; // <-- match your API
  RxInt projectId = 0.obs;

  // ── API Params (search + sort) ───────────────────────────────────
  final RxString _currentKeyword = ''.obs;
  final RxString _currentOrderBy = ''.obs; // '' = no order, 'asc' or 'desc'
  final RxBool isAscending = true.obs; // UI only (icon)

  // ── Debounce ─────────────────────────────────────────────────────
  Timer? _searchDebounce;

  // -----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    // Grab project id from navigation arguments
    final args = Get.arguments as String;
    projectId.value = int.parse(args);
    log("PackageListController → projectId = ${projectId.value}");

    // Reset sort & keyword
    _currentOrderBy.value = '';
    isAscending.value = true;

    // First load
    fetchPackages(reset: true, context: Get.context!);
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  // -----------------------------------------------------------------
  // Build query string (keyword, order_by, pagination)
  // -----------------------------------------------------------------
  String _buildQueryParams({bool includePagination = true}) {
    final List<String> parts = [];

    if (_currentKeyword.value.isNotEmpty) {
      parts.add('keyword=${Uri.encodeComponent(_currentKeyword.value)}');
    }

    if (_currentOrderBy.value.isNotEmpty) {
      parts.add('order_by=${_currentOrderBy.value}');
    }

    parts.add('project_id=${projectId.value}');

    if (includePagination) {
      parts.add('start=${offset.value}');
      parts.add('length=$limit');
    }

    return parts.isNotEmpty ? '?${parts.join('&')}' : '';
  }

  // -----------------------------------------------------------------
  // FETCH PACKAGES (core API call)
  // -----------------------------------------------------------------
  Future<void> fetchPackages({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    // ---- Reset handling -------------------------------------------------
    if (reset) {
      offset.value = 0;
      packages.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !reset) {
      log('No more data to fetch');
      return;
    }

    // ---- Loading state --------------------------------------------------
    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final String query = _buildQueryParams(includePagination: true);
      final String endpoint = Networkutility.getPackagesList + query;

      log('API → $endpoint');

      final response =
          await Networkcall().getMethod(
                Networkutility.getPackagesListApi,
                endpoint,
                context,
              )
              as List<GetPackageNameResponse>?;

      // ---- SUCCESS --------------------------------------------------------
      if (response != null && response.isNotEmpty) {
        final apiResponse = response[0];

        if (apiResponse.status == true) {
          final List<PackageData> apiData = apiResponse.data;

          // ---- Pagination guard -------------------------------------------
          if (apiData.isEmpty || apiData.length < limit) {
            hasMoreData.value = false;
          }

          // ---- Map API → UI model -----------------------------------------
          final List<PackageData> newPackages = apiData.map((p) {
            return PackageData(
              packageId: p.packageId,
              packageName: p.packageName,
              projectId: p.projectId,
              projectCode: p.projectCode,
              projectName: p.projectName,
              packageValue: p.packageValue,
            );
          }).toList();

          // ---- Append / replace --------------------------------------------
          if (reset) {
            packages.assignAll(newPackages);
          } else {
            packages.addAll(newPackages);
          }

          // UI list = full list (search/sort will filter it later)
          filteredPackages.assignAll(packages);

          offset.value += limit;

          log(
            'Fetched ${newPackages.length} packages | Total: ${packages.length}',
          );
        } else {
          // ---- API status:false -------------------------------------------
          hasMoreData.value = false;
          errorMessage.value = apiResponse.message ?? 'No data';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: errorMessage.value,
          );
        }
      } else {
        // ---- No Data -----------------------------------------------
        hasMoreData.value = false;
        errorMessage.value = 'No Data';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    }
    // ---- EXCEPTIONS -------------------------------------------------------
    on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: errorMessage.value,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // -----------------------------------------------------------------
  // DEBOUNCED SEARCH
  // -----------------------------------------------------------------
  void searchPackages(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      if (_currentKeyword.value != trimmed) {
        _currentKeyword.value = trimmed;
        fetchPackages(reset: true, context: Get.context!);
      }
    });
  }

  // -----------------------------------------------------------------
  // TOGGLE SORT (asc / desc) → API
  // -----------------------------------------------------------------
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _currentOrderBy.value = isAscending.value ? 'asc' : 'desc';
    fetchPackages(reset: true, context: Get.context!);
  }

  // -----------------------------------------------------------------
  // LOAD MORE (pagination)
  // -----------------------------------------------------------------
  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchPackages(context: context, isPagination: true);
    }
  }

  // -----------------------------------------------------------------
  // REFRESH (pull-to-refresh)
  // -----------------------------------------------------------------
  Future<void> refreshData() async {
    searchController.clear();
    _currentKeyword.value = '';
    _currentOrderBy.value = '';
    isAscending.value = true;
    await fetchPackages(reset: true, context: Get.context!);
  }

  // -----------------------------------------------------------------
  // FILTER BY DROPDOWN (optional – keep if you still need it)
  // -----------------------------------------------------------------
  final RxnString selectedPackageFilter = RxnString(null);

  void applyDropdownFilter() {
    if (selectedPackageFilter.value == null) {
      filteredPackages.assignAll(packages);
    } else {
      filteredPackages.assignAll(
        packages
            .where((p) => p.packageName == selectedPackageFilter.value)
            .toList(),
      );
    }
  }

  void clearDropdownFilter() {
    selectedPackageFilter.value = null;
    filteredPackages.assignAll(packages);
  }

  // -----------------------------------------------------------------
  // VIEW PACKAGE
  // -----------------------------------------------------------------
  void viewPackage(PackageData package) {
    log('Viewing package: ${package.packageName} (ID: ${package.packageId})');
    // Navigate or show dialog
  }
}
