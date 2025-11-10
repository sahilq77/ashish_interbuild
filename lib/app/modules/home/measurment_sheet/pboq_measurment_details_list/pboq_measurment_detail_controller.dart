import 'package:ashishinterbuild/app/data/models/pboq/pboq_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PboqMeasurmentDetailController extends GetxController {
  // Reactive list of PBOQ items
  final RxList<PboqModel> pboqList = <PboqModel>[].obs;

  // Reactive list for filtered PBOQ items
  final RxList<PboqModel> filteredPboqList = <PboqModel>[].obs;

  // Reactive variable for expanded card index
  final RxInt expandedIndex = (-1).obs;

  // Reactive variable for loading state
  final RxBool isLoading = true.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchPboqData();
    // Listen to search query changes
    searchController.addListener(() {
      searchPboq(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Fetch PBOQ data (simulated with dummy data)
  Future<void> fetchPboqData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    pboqList.assignAll([
      PboqModel(
        systemId: "SYS001",
        source: "Manual",
        cboqCode: "CB001",
        pboq: "PBOQ-001",
        pboa: "PBOA-001",
        zone: "Zone A",
        location: "Building 1",
        subLocation: "Floor 1",
        uom: "m²",
        nos: 5,
        length: 10.5,
        breadth: 5.0,
        height: 3.0,
        deduction: 1.0,
        msQty: 50,
        remark: "Completed",
        updatedOn: DateTime(2025, 10, 13),
        packageName: "Package 1",
        cboqName: "CBOQ-001",
        pboqQty: "45",
      ),
      PboqModel(
        systemId: "SYS002",
        source: "Auto",
        cboqCode: "CB002",
        pboq: "PBOQ-002",
        pboa: "PBOA-002",
        zone: "Zone B",
        location: "Building 2",
        subLocation: "Floor 2",
        uom: "m³",
        nos: 3,
        length: 8.0,
        breadth: 4.0,
        height: 2.5,
        deduction: 0.5,
        msQty: 30,
        remark: "In Progress",
        updatedOn: DateTime(2025, 10, 12),
        packageName: "Package 2",
        cboqName: "CBOQ-002",
        pboqQty: "28",
      ),
    ]);
    filteredPboqList.assignAll(pboqList); // Initialize filtered list
    isLoading.value = false;
  }

  // Refresh data
  Future<void> refreshData() async {
    isLoading.value = true;
    searchController.clear(); // Clear search query
    pboqList.clear();
    filteredPboqList.clear();
    await fetchPboqData(); // Reload data
  }

  // Toggle expanded state of a card
  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  // View PBOQ details
  void viewPboqDetails(PboqModel pboq) {
    print("Viewing details for ${pboq.pboq}");
    // Implement navigation or dialog for viewing details
  }

  // Search PBOQ items
  // void searchPboq(String query) {
  //   if (query.isEmpty) {
  //     filteredPboqList.assignAll(pboqList);
  //   } else {
  //     filteredPboqList.assignAll(
  //       pboqList
  //           .where(
  //             (pboq) =>
  //                 pboq.packageName.toLowerCase().contains(
  //                   query.toLowerCase(),
  //                 ) ||
  //                 pboq.cboqName.toLowerCase().contains(query.toLowerCase()),
  //           )
  //           .toList(),
  //     );
  //   }
  // }

  // Filter & Sort Variables
  final RxnString selectedPackageFilter = RxnString(null);
  final RxBool isAscending = true.obs;

  // Get unique package names for filter dropdown
  List<String> getPackageNames() {
    return pboqList.map((sheet) => sheet.packageName).toSet().toList();
  }

  // Apply filters (called from dialog)
  void applyFilters() {
    var filtered = pboqList.toList();

    if (selectedPackageFilter.value != null) {
      filtered = filtered
          .where((sheet) => sheet.packageName == selectedPackageFilter.value)
          .toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (sheet) =>
                sheet.packageName.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                sheet.cboqName.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    filteredPboqList.assignAll(filtered);
    applySorting();
  }

  // Clear all filters
  void clearFilters() {
    selectedPackageFilter.value = null;
    searchController.clear();
    filteredPboqList.assignAll(pboqList);
    applySorting();
  }

  // Toggle sort order
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    applySorting();
  }

  // Apply sorting by CBOQ Name
  void applySorting() {
    if (isAscending.value) {
      filteredPboqList.sort((a, b) => a.cboqName.compareTo(b.cboqName));
    } else {
      filteredPboqList.sort((a, b) => b.cboqName.compareTo(a.cboqName));
    }
  }

  // Update search to re-apply filters + sorting
  void searchPboq(String query) {
    if (query.isEmpty && selectedPackageFilter.value == null) {
      filteredPboqList.assignAll(pboqList);
    } else {
      applyFilters(); // This will respect both search + filter
    }
    applySorting();
  }
}
