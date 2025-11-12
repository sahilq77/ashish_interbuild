import 'package:ashishinterbuild/app/data/models/work_front_update/work_front_update_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkFrontUpdateListController extends GetxController {
  // ------------------------------------------------------------------
  // Reactive data
  // ------------------------------------------------------------------
  final RxList<WorkFrontUpdateModel> items = <WorkFrontUpdateModel>[].obs;
  final RxList<WorkFrontUpdateModel> filteredMeasurementSheets = <WorkFrontUpdateModel>[].obs;
  final RxInt expandedIndex = (-1).obs;
  final RxBool isLoading = true.obs;

  // Search & Filter
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedPackageFilter = RxnString();
  final RxnString selectedZoneFilter = RxnString(); // <<< NEW: Zone filter
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
  // Dummy data
  // ------------------------------------------------------------------
  Future<void> loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final dummy = [
      WorkFrontUpdateModel(
        srNo: 1,
        systemId: 335,
        packageName: "Ashok Package",
        cboqCode: "C002",
        pboq: "CBOQ-2",
        pboa: "Floor leveling",
        pboaQty: 300,
        pboaRate: 0.30,
        doer: "-",
        uom: "SMT",
        fix: "ID1",
        trade: "Civil",
        zone: "Private Zone,Public Zone",
        rate: 0.30,
        amount: 90.00,
        msQty: 300,
        cumRecQty: 0,
        cumRecAmount: 0.0,
        workFrontRecAmount: "0.00%",
      ),
      WorkFrontUpdateModel(
        srNo: 2,
        systemId: 336,
        packageName: "Ravi Package",
        cboqCode: "C003",
        pboq: "CBOQ-3",
        pboa: "Wall plaster",
        pboaQty: 500,
        pboaRate: 0.45,
        doer: "-",
        uom: "SMT",
        fix: "ID2",
        trade: "Civil",
        zone: "Public Zone",
        rate: 0.45,
        amount: 225.00,
        msQty: 500,
        cumRecQty: 0,
        cumRecAmount: 0.0,
        workFrontRecAmount: "0.00%",
      ),
      WorkFrontUpdateModel(
        srNo: 3,
        systemId: 337,
        packageName: "Ashok Package",
        cboqCode: "C004",
        pboq: "CBOQ-4",
        pboa: "Ceiling work",
        pboaQty: 200,
        pboaRate: 0.60,
        doer: "-",
        uom: "SMT",
        fix: "ID3",
        trade: "Civil",
        zone: "Private Zone",
        rate: 0.60,
        amount: 120.00,
        msQty: 200,
        cumRecQty: 0,
        cumRecAmount: 0.0,
        workFrontRecAmount: "0.00%",
      ),
      WorkFrontUpdateModel(
        srNo: 4,
        systemId: 338,
        packageName: "Ravi Package",
        cboqCode: "C005",
        pboq: "CBOQ-5",
        pboa: "Painting",
        pboaQty: 400,
        pboaRate: 0.25,
        doer: "-",
        uom: "SMT",
        fix: "ID4",
        trade: "Finishing",
        zone: "Public Zone,Private Zone",
        rate: 0.25,
        amount: 100.00,
        msQty: 400,
        cumRecQty: 0,
        cumRecAmount: 0.0,
        workFrontRecAmount: "0.00%",
      ),
      WorkFrontUpdateModel(
        srNo: 5,
        systemId: 339,
        packageName: "Suresh Package",
        cboqCode: "C006",
        pboq: "CBOQ-6",
        pboa: "Tile work",
        pboaQty: 150,
        pboaRate: 0.80,
        doer: "-",
        uom: "SMT",
        fix: "ID5",
        trade: "Finishing",
        zone: "Private Zone",
        rate: 0.80,
        amount: 120.00,
        msQty: 150,
        cumRecQty: 0,
        cumRecAmount: 0.0,
        workFrontRecAmount: "0.00%",
      ),
    ];

    items.assignAll(dummy);
    filteredMeasurementSheets.assignAll(items);
    isLoading.value = false;
  }

  // ------------------------------------------------------------------
  // Refresh
  // ------------------------------------------------------------------
  Future<void> refreshData() async {
    items.clear();
    filteredMeasurementSheets.clear();
    await loadDummyData();
    searchController.clear();
    selectedPackageFilter.value = null;
    selectedZoneFilter.value = null; // <<< Reset zone filter
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
  List<String> getPackageNames() =>
      items.map((e) => e.packageName).toSet().toList();

  List<String> getZoneNames() => // <<< NEW: Get unique zones
      items.map((e) => e.zone).where((z) => z.isNotEmpty).toSet().toList();

  void applyFilters() {
    var list = items.toList();

    // ---- Package filter ----
    if (selectedPackageFilter.value != null) {
      list = list
          .where((e) => e.packageName == selectedPackageFilter.value)
          .toList();
    }

    // ---- Zone filter ----
    if (selectedZoneFilter.value != null) {
      list = list
          .where((e) => e.zone == selectedZoneFilter.value)
          .toList();
    }

    // ---- Search ----
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((e) =>
          e.packageName.toLowerCase().contains(query) ||
          e.cboqCode.toLowerCase().contains(query) ||
          e.pboa.toLowerCase().contains(query) ||
          e.zone.toLowerCase().contains(query)).toList();
    }

    // ---- Sort by CBOQ Code ----
    list.sort((a, b) => isAscending.value
        ? a.cboqCode.compareTo(b.cboqCode)
        : b.cboqCode.compareTo(a.cboqCode));

    filteredMeasurementSheets.assignAll(list);
  }

  void toggleSorting() {
    isAscending.value = !isAscending.value;
    applyFilters();
  }

  void clearFilters() {
    selectedPackageFilter.value = null;
    selectedZoneFilter.value = null; // <<< Clear zone
    searchController.clear();
    applyFilters();
  }

  void searchSurveys(String _) => applyFilters();
}