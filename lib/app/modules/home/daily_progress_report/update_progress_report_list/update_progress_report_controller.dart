import 'package:ashishinterbuild/app/data/models/daily_progress_report/daily_progress_report_model.dart';
import 'package:ashishinterbuild/app/data/models/daily_progress_report/update_daily_progress_report_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UpdateProgressReportController extends GetxController {
  final RxList<UpdateDailyProgressReportModel> measurementSheets =
      <UpdateDailyProgressReportModel>[].obs;
  final RxList<UpdateDailyProgressReportModel> filteredMeasurementSheets =
      <UpdateDailyProgressReportModel>[].obs;
  final RxInt expandedIndex = (-1).obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
    filteredMeasurementSheets.assignAll(measurementSheets);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadDummyData() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2));
    measurementSheets.assignAll([
      UpdateDailyProgressReportModel(
        srNo: "1",
        systemId: "SYS001",
        source: "Source A",
        zone: "Zone A",
        location: "Location 1",
        subLocation: "Sub Loc 1",
        cboqCode: "CBOQ001",
        pboq: "PBOQ001",
        pboa: "PBOA001",
        pboaQty: "50",
        pboaAmount: "5000",
        revisedStartDate: "2025-10-01",
        revisedEndDate: "2025-10-15",
        length: "10",
        breadth: "5",
        height: "3",
        msQty: "50",
        uploadedFile: "file1.pdf",
        progress: "75%",
        execution: "Completed",
        updatedOn: "2025-10-10",
      ),
      UpdateDailyProgressReportModel(
        srNo: "2",
        systemId: "SYS002",
        source: "Source B",
        zone: "Zone B",
        location: "Location 2",
        subLocation: "Sub Loc 2",
        cboqCode: "CBOQ002",
        pboq: "PBOQ002",
        pboa: "PBOA002",
        pboaQty: "75",
        pboaAmount: "7500",
        revisedStartDate: "2025-10-02",
        revisedEndDate: "2025-10-16",
        length: "12",
        breadth: "6",
        height: "4",
        msQty: "75",
        uploadedFile: "file2.pdf",
        progress: "50%",
        execution: "In Progress",
        updatedOn: "2025-10-11",
      ),
      UpdateDailyProgressReportModel(
        srNo: "3",
        systemId: "SYS003",
        source: "Source C",
        zone: "Zone C",
        location: "Location 3",
        subLocation: "Sub Loc 3",
        cboqCode: "CBOQ003",
        pboq: "PBOQ003",
        pboa: "PBOA003",
        pboaQty: "30",
        pboaAmount: "3000",
        revisedStartDate: "2025-10-03",
        revisedEndDate: "2025-10-17",
        length: "8",
        breadth: "4",
        height: "2",
        msQty: "30",
        uploadedFile: "file3.pdf",
        progress: "90%",
        execution: "Completed",
        updatedOn: "2025-10-12",
      ),
      UpdateDailyProgressReportModel(
        srNo: "4",
        systemId: "SYS004",
        source: "Source D",
        zone: "Zone D",
        location: "Location 4",
        subLocation: "Sub Loc 4",
        cboqCode: "CBOQ004",
        pboq: "PBOQ004",
        pboa: "PBOA004",
        pboaQty: "90",
        pboaAmount: "9000",
        revisedStartDate: "2025-10-04",
        revisedEndDate: "2025-10-18",
        length: "15",
        breadth: "7",
        height: "5",
        msQty: "90",
        uploadedFile: "file4.pdf",
        progress: "60%",
        execution: "In Progress",
        updatedOn: "2025-10-13",
      ),
    ]);
    filteredMeasurementSheets.assignAll(measurementSheets);
    isLoading.value = false;
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    measurementSheets.clear();
    filteredMeasurementSheets.clear();
    await Future.delayed(Duration(seconds: 2));
    await loadDummyData();
    searchController.clear();
  }

  void viewMeasurementSheet(UpdateDailyProgressReportModel sheet) {
    print('Viewing: ${sheet.pboa}');
  }

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  // void searchSurveys(String query) {
  //   if (query.isEmpty) {
  //     filteredMeasurementSheets.assignAll(measurementSheets);
  //   } else {
  //     filteredMeasurementSheets.assignAll(
  //       measurementSheets
  //           .where(
  //             (sheet) =>
  //                 sheet.pboa.toLowerCase().contains(query.toLowerCase()) ||
  //                 sheet.zone.toLowerCase().contains(query.toLowerCase()) ||
  //                 sheet.location.toLowerCase().contains(query.toLowerCase()),
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
    return measurementSheets.map((sheet) => sheet.location).toSet().toList();
  }

  // Apply filters (called from dialog)
  void applyFilters() {
    var filtered = measurementSheets.toList();

    if (selectedPackageFilter.value != null) {
      filtered = filtered
          .where((sheet) => sheet.location == selectedPackageFilter.value)
          .toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (sheet) =>
                sheet.location.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                sheet.pboa.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    filteredMeasurementSheets.assignAll(filtered);
    applySorting();
  }

  // Clear all filters
  void clearFilters() {
    selectedPackageFilter.value = null;
    searchController.clear();
    filteredMeasurementSheets.assignAll(measurementSheets);
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
      filteredMeasurementSheets.sort(
        (a, b) => a.pboa.compareTo(b.pboa),
      );
    } else {
      filteredMeasurementSheets.sort(
        (a, b) => b.pboa.compareTo(a.pboa),
      );
    }
  }

  // Update search to re-apply filters + sorting
  void searchSurveys(String query) {
    if (query.isEmpty && selectedPackageFilter.value == null) {
      filteredMeasurementSheets.assignAll(measurementSheets);
    } else {
      applyFilters(); // This will respect both search + filter
    }
    applySorting();
  }
}
