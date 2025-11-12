import 'package:ashishinterbuild/app/data/models/work_front_update/work_front_update_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkFrontUpdateDetailListController extends GetxController {
  // ------------------------------------------------------------------
  // Reactive data
  // ------------------------------------------------------------------
  final RxList<WorkFrontUpdateDetailModel> items =
      <WorkFrontUpdateDetailModel>[].obs;
  final RxList<WorkFrontUpdateDetailModel> filteredMeasurementSheets =
      <WorkFrontUpdateDetailModel>[].obs;
  final RxList<MeasurementSheetModel> measurementSheets =
      <MeasurementSheetModel>[].obs;

  final RxInt expandedIndex = (-1).obs;
  final RxBool isLoading = true.obs;

  // Search & Filter
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedPackageFilter = RxnString();
  final RxnString selectedZoneFilter = RxnString();
  final RxnString selectedLocationFilter =
      RxnString(); // <-- NEW: Location Filter
  final RxBool isAscending = true.obs;

  // ------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    loadDummyData();
    searchController.addListener(applyFilters);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ------------------------------------------------------------------
  // Dummy data - EXACTLY matches your screenshots
  // ------------------------------------------------------------------
  Future<void> loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final dummyWorkFront = [
      WorkFrontUpdateDetailModel(
        source: "pboq",
        zone: "Private Zone",
        location: "Bedrooms",
        subLocation: "Bedroom sub location",
        cboqCode: "C002",
        pboq: "CBOQ-2",
        pboa: "Floor leveling",
        systemId: 335,
        pboaQty: 300.00,
        pboaAmount: 90.00,
        revisedStartDate: DateTime(2025, 11, 5),
        revisedEndDate: DateTime(2025, 11, 12),
      ),
      WorkFrontUpdateDetailModel(
        source: "pboq",
        zone: "Private Zone",
        location: "Bedrooms",
        subLocation: "Bedroom sub location",
        cboqCode: "C002",
        pboq: "CBOQ-2",
        pboa: "Floor leveling",
        systemId: 335,
        pboaQty: 300.00,
        pboaAmount: 90.00,
        revisedStartDate: DateTime(2025, 11, 5),
        revisedEndDate: DateTime(2025, 11, 12),
      ),
    ];

    final dummyMS = [
      MeasurementSheetModel(
        nos: 1,
        length: 10.00,
        breadth: 5.00,
        height: 3.00,
        msQty: 150.00,
        lastUploadedFile: null,
        progressUpdatedOn: null,
        receivedDate: null,
      ),
      MeasurementSheetModel(
        nos: 1,
        length: 10.00,
        breadth: 5.00,
        height: 3.00,
        msQty: 150.00,
        lastUploadedFile: null,
        progressUpdatedOn: null,
        receivedDate: null,
      ),
    ];

    items.assignAll(dummyWorkFront);
    measurementSheets.assignAll(dummyMS);
    filteredMeasurementSheets.assignAll(items);
    isLoading.value = false;
  }

  // ------------------------------------------------------------------
  // Refresh
  // ------------------------------------------------------------------
  Future<void> refreshData() async {
    items.clear();
    filteredMeasurementSheets.clear();
    measurementSheets.clear();
    await loadDummyData();
    searchController.clear();
    selectedPackageFilter.value = null;
    selectedZoneFilter.value = null;
    selectedLocationFilter.value = null; // <-- Reset location filter
  }

  // ------------------------------------------------------------------
  // Expand / Collapse
  // ------------------------------------------------------------------
  void toggleExpanded(int index) {
    expandedIndex.value = (expandedIndex.value == index) ? -1 : index;
  }

  // ------------------------------------------------------------------
  // ---------- FILTER & SORT ----------
  // ------------------------------------------------------------------
  List<String> getPackageNames() => items.map((e) => e.pboq).toSet().toList();

  List<String> getZoneNames() => items.map((e) => e.zone).toSet().toList();

  List<String> getLocationNames() => // <-- NEW: Location dropdown options
      items.map((e) => e.location).toSet().toList();

  void applyFilters() {
    var list = items.toList();

    // ---- Package filter (PBOQ) ----
    if (selectedPackageFilter.value != null) {
      list = list.where((e) => e.pboq == selectedPackageFilter.value).toList();
    }

    // ---- Zone filter ----
    if (selectedZoneFilter.value != null) {
      list = list.where((e) => e.zone == selectedZoneFilter.value).toList();
    }

    // ---- Location filter (NEW) ----
    if (selectedLocationFilter.value != null) {
      list = list
          .where((e) => e.location == selectedLocationFilter.value)
          .toList();
    }

    // ---- Search ----
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.pboq.toLowerCase().contains(query) ||
                e.cboqCode.toLowerCase().contains(query) ||
                e.pboa.toLowerCase().contains(query) ||
                e.zone.toLowerCase().contains(query) ||
                e.location.toLowerCase().contains(
                  query,
                ), // <-- Added location to search
          )
          .toList();
    }

    // ---- Sort by CBOQ Code ----
    list.sort(
      (a, b) => isAscending.value
          ? a.cboqCode.compareTo(b.cboqCode)
          : b.cboqCode.compareTo(a.cboqCode),
    );

    filteredMeasurementSheets.assignAll(list);
  }

  void toggleSorting() {
    isAscending.value = !isAscending.value;
    applyFilters();
  }

  void clearFilters() {
    selectedPackageFilter.value = null;
    selectedZoneFilter.value = null;
    selectedLocationFilter.value = null; // <-- Clear location filter
    searchController.clear();
    applyFilters();
  }

  void searchSurveys(String _) => applyFilters();
}
