import 'package:ashishinterbuild/app/data/models/client_commitment/client_commitment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ClientCommitmentController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxInt expandedIndex = (-1).obs;
  final RxList<ClientCommitmentModel> commitmentList = <ClientCommitmentModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      // Simulate API call or data fetching
      await Future.delayed(const Duration(seconds: 1));
      commitmentList.assignAll([
        ClientCommitmentModel(
          srNo: 1,
          taskAssignedTo: "Savant Akash",
          hod: "tester",
          taskDetails: "testing",
          affectedMilestone: "Milestone One",
          priority: "-",
          milestoneTargetDate: DateTime(2025, 10, 15),
          initialTargetDate: DateTime(2025, 10, 19),
          ccCategory: "Design Approval",
          overdueDays: 0,
          delay: "-",
          revisedCompletionDate: null,
          closeDate: null,
          statusUpdate: "Pending",
          attachment: "View",
          remark: "-",
        ),
        // Add more sample data as needed
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  void searchCommitments(String query) {
    if (query.isEmpty) {
      fetchData();
    } else {
      commitmentList.assignAll(commitmentList.where((item) {
        return item.taskDetails.toLowerCase().contains(query.toLowerCase()) ||
            item.taskAssignedTo.toLowerCase().contains(query.toLowerCase()) ||
            item.affectedMilestone.toLowerCase().contains(query.toLowerCase()) ||
            item.ccCategory.toLowerCase().contains(query.toLowerCase());
      }).toList());
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}