import 'package:ashishinterbuild/app/data/models/pboq/pboq_model.dart' show PboqModel;
import 'package:get/get.dart';

class PboqMeasurmentDetailController extends GetxController {
  var isLoading = true.obs;
  var expandedIndex = (-1).obs;
  var pboqList = <PboqModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPboqData();
  }

  void fetchPboqData() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    // Dummy data initialization
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
    isLoading.value = false;
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1)); // Simulate refresh
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
    isLoading.value = false;
  }

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  void viewPboqDetails(PboqModel pboq) {
    // Implement navigation or action to view details
    print("Viewing details for ${pboq.pboq}");
  }
}