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
  // ── Existing ─────────────────────────────────────────────────────
  final RxList<PackageData> packages = <PackageData>[].obs;
  final RxList<PackageData> filteredPackages = <PackageData>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedPackageFilter = RxnString(null);
  final RxBool isAscending = true.obs;

  // ── New (pagination) ───────────────────────────────────────────
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt offset = 0.obs;
  final int limit = 20; // change to whatever your API expects
  final RxList<PackageData> packageList = <PackageData>[].obs; // internal list
  RxInt projectId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as String;
    projectId.value = int.parse(args);
    print("id $args");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchPackages(
        reset: true,
        context: Get.context!,
        id: projectId.value,
      );
    });

    filteredPackages.assignAll(packages); // keep UI in sync
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// -----------------------------------------------------------
  /// Fetch packages from the real API
  /// -----------------------------------------------------------
  Future<void> fetchPackages({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    int id = 0,
  }) async {
    // ---- reset ------------------------------------------------
    if (reset) {
      offset.value = 0;
      packageList.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !reset) {
      log('No more data to fetch');
      return;
    }

    // ---- loading state ----------------------------------------
    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      // ---- API CALL -------------------------------------------
      final response =
          await Networkcall().getMethod(
                Networkutility.getPackagesListApi, // endpoint constant
                Networkutility.getPackagesList +
                    "?project_id=$id", // query-params if any
                context,
              )
              as List<GetPackageNameResponse>?;

      // ---- SUCCESS --------------------------------------------
      if (response != null && response.isNotEmpty) {
        final apiResponse = response[0];
        if (apiResponse.status == true) {
          final List<PackageData> apiData = apiResponse.data;

          // stop pagination if we got less than limit
          if (apiData.isEmpty || apiData.length < limit) {
            hasMoreData.value = false;
          }

          // ---- Convert API model → UI model --------------------
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

          packageList.addAll(newPackages);
          packages.assignAll(packageList); // UI list
          filteredPackages.assignAll(packageList); // filtered list
          offset.value += limit;

          log(
            'Fetched ${newPackages.length} packages – offset: ${offset.value}',
          );
        } else {
          // ---- API returned status:false -----------------------
          hasMoreData.value = false;
          errorMessage.value = apiResponse.message ?? 'No data';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: errorMessage.value,
          );
        }
      } else {
        // ---- No response ---------------------------------------
        hasMoreData.value = false;
        errorMessage.value = 'Empty response';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    }
    // ---- EXCEPTIONS -------------------------------------------
    on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // -----------------------------------------------------------------
  // Refresh
  // -----------------------------------------------------------------
  Future<void> refreshData() async {
    searchController.clear();
    selectedPackageFilter.value = null;
    await fetchPackages(reset: true, context: Get.context!);
  }

  // -----------------------------------------------------------------
  // Load more (pagination)
  // -----------------------------------------------------------------
  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchPackages(context: context, isPagination: true);
    }
  }

  // -----------------------------------------------------------------
  // View a package
  // -----------------------------------------------------------------
  void viewPackage(PackageData package) {
    print('Viewing: ${package.packageName}');
  }

  // -----------------------------------------------------------------
  // Search
  // -----------------------------------------------------------------
  void searchPackages(String query) {
    if (query.isEmpty) {
      filteredPackages.assignAll(packages);
    } else {
      filteredPackages.assignAll(
        packages
            .where(
              (pkg) =>
                  pkg.packageName.toLowerCase().contains(query.toLowerCase()),
              // pkg..toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
    applySorting();
  }

  // -----------------------------------------------------------------
  // Unique package names for filter dropdown
  // -----------------------------------------------------------------
  List<String> getPackageNames() {
    return packages.map((p) => p.packageName).toSet().toList();
  }

  // -----------------------------------------------------------------
  // Apply filters
  // -----------------------------------------------------------------
  void applyFilters() {
    var filtered = packages.toList();

    if (selectedPackageFilter.value != null) {
      filtered = filtered
          .where((p) => p.packageName == selectedPackageFilter.value)
          .toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.packageName.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
            // ||
            // p.clientName.toLowerCase().contains(
            //   searchController.text.toLowerCase(),
            // ),
          )
          .toList();
    }

    filteredPackages.assignAll(filtered);
    applySorting();
  }

  // -----------------------------------------------------------------
  // Clear filters
  // -----------------------------------------------------------------
  void clearFilters() {
    selectedPackageFilter.value = null;
    searchController.clear();
    filteredPackages.assignAll(packages);
    applySorting();
  }

  // -----------------------------------------------------------------
  // Toggle sorting order
  // -----------------------------------------------------------------
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    applySorting();
  }

  // -----------------------------------------------------------------
  // Apply sorting (by packageName)
  // -----------------------------------------------------------------
  void applySorting() {
    if (isAscending.value) {
      filteredPackages.sort((a, b) => a.packageName.compareTo(b.packageName));
    } else {
      filteredPackages.sort((a, b) => b.packageName.compareTo(a.packageName));
    }
  }
}
