import 'package:ashishinterbuild/app/data/models/daily_progress_report/daily_progress_report_model.dart';
import 'package:ashishinterbuild/app/data/models/measurement_sheet/measurment_sheet_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UpdateProgressReportController extends GetxController {
  // Reactive list of measurement sheets
  final RxList<DailyProgressReportModel> measurementSheets =
      <DailyProgressReportModel>[].obs;

  // Reactive list for filtered measurement sheets
  final RxList<DailyProgressReportModel> filteredMeasurementSheets =
      <DailyProgressReportModel>[].obs;

  // Reactive variable to track the index of the expanded card
  final RxInt expandedIndex = (-1).obs; // -1 means no card is expanded

  // Reactive variable to track loading state
  final RxBool isLoading = true.obs;

  // TextEditingController for the search field
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Load dummy data when controller is initialized
    loadDummyData();
    // Initialize filtered list with all measurement sheets
    filteredMeasurementSheets.assignAll(measurementSheets);
  }

  @override
  void onClose() {
    // Dispose of the search controller
    searchController.dispose();
    super.onClose();
  }

  // Function to load dummy data
  Future<void> loadDummyData() async {
    isLoading.value = true;
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    measurementSheets.assignAll([
      DailyProgressReportModel(
        packageName: "Prime Package",
        cboqName: "CBOQ001",
        msQty: "10000",
        pboqName: "CBOQ-1",
        zones: "Business Zone, Private Zone, Public Zone",
        uom: "SFT",
        pboqQty: "10000",
        pboa: "Final painting work",
        todaysTargetPboaQuantity: "0.00",
        todaysAchieveQuantity: "0.00",
             pboaQuantity: "11000"
      ),
      DailyProgressReportModel(
        packageName: "Standard Package",
        cboqName: "CBOQ002",
        msQty: "8000",
        pboqName: "CBOQ-2",
        zones: "Residential Zone, Commercial Zone",
        uom: "SFT",
        pboqQty: "8500",
        pboa: "Base painting work",
        todaysTargetPboaQuantity: "0.00",
        todaysAchieveQuantity: "0.00",
             pboaQuantity: "11000"
      ),
      DailyProgressReportModel(
        packageName: "Premium Package",
        cboqName: "CBOQ003",
        msQty: "12000",
        pboqName: "CBOQ-3",
        zones: "Industrial Zone, Public Zone",
        uom: "SFT",
        pboqQty: "12500",
        pboa: "Factory Item Installation",
        todaysTargetPboaQuantity: "0.00",
        todaysAchieveQuantity: "0.00",
             pboaQuantity: "11000"
      ),
    ]);
    // Update filtered list after loading data
    filteredMeasurementSheets.assignAll(measurementSheets);
    isLoading.value = false;
  }

  // Function to handle refresh
  Future<void> refreshData() async {
    isLoading.value = true;
    // Clear existing data
    measurementSheets.clear();
    filteredMeasurementSheets.clear();
    // Simulate network delay and reload data
    await Future.delayed(Duration(seconds: 2));
    await loadDummyData();
    // Reset search
    searchController.clear();
  }

  // Function to handle view action
  void viewMeasurementSheet(DailyProgressReportModel sheet) {
    // Implement navigation or dialog to view details
    print('Viewing: ${sheet.packageName}');
  }

  // Function to toggle the expanded state of a card
  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Collapse if the same card is clicked
    } else {
      expandedIndex.value = index; // Expand the clicked card
    }
  }

  // Function to handle search
  void searchSurveys(String query) {
    if (query.isEmpty) {
      // If search query is empty, show all measurement sheets
      filteredMeasurementSheets.assignAll(measurementSheets);
    } else {
      // Filter measurement sheets based on packageName or cboqName
      filteredMeasurementSheets.assignAll(
        measurementSheets
            .where(
              (sheet) =>
                  sheet.packageName.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  sheet.cboqName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
  }
}
