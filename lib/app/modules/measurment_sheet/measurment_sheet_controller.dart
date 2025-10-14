import 'package:ashishinterbuild/app/data/models/measurement_sheet/measurment_sheet_model.dart';
import 'package:get/get.dart';

class MeasurementSheetController extends GetxController {
  // Reactive list of measurement sheets
  final RxList<MeasurementSheet> measurementSheets = <MeasurementSheet>[].obs;

  // Reactive variable to track the index of the expanded card
  final RxInt expandedIndex = (-1).obs; // -1 means no card is expanded

  // Reactive variable to track loading state
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Load dummy data when controller is initialized
    loadDummyData();
  }

  // Function to load dummy data
  Future<void> loadDummyData() async {
    isLoading.value = true;
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    measurementSheets.assignAll([
      MeasurementSheet(
        packageName: "Prime Package",
        cboqName: "CBOQ001",
        msQty: "10000",
        pboqName: "CBOQ-1",
        zones: "Business Zone, Private Zone, Public Zone",
        uom: "SFT",
        pboqQty: "10000",
      ),
      MeasurementSheet(
        packageName: "Standard Package",
        cboqName: "CBOQ002",
        msQty: "8000",
        pboqName: "CBOQ-2",
        zones: "Residential Zone, Commercial Zone",
        uom: "SFT",
        pboqQty: "8500",
      ),
      MeasurementSheet(
        packageName: "Premium Package",
        cboqName: "CBOQ003",
        msQty: "12000",
        pboqName: "CBOQ-3",
        zones: "Industrial Zone, Public Zone",
        uom: "SFT",
        pboqQty: "12500",
      ),
    ]);
    isLoading.value = false;
  }

  // Function to handle refresh
  Future<void> refreshData() async {
    isLoading.value = true;
    // Clear existing data
    measurementSheets.clear();
    // Simulate network delay and reload data
    await Future.delayed(Duration(seconds: 2));
    loadDummyData();
  }

  // Function to handle view action
  void viewMeasurementSheet(MeasurementSheet sheet) {
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
}
