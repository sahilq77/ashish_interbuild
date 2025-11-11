import 'package:ashishinterbuild/app/data/models/acc/acc_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccController extends GetxController {
  var isLoading = true.obs;
  var accList = <AccModel>[].obs;
  final searchController = TextEditingController();
  var expandedIndex = (-1).obs; // Track the expanded card index, -1 means none expanded

  @override
  void onInit() {
    super.onInit();
    fetchAcc();
  }

  Future<void> fetchAcc() async {
    isLoading.value = true;
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    var data = [
      {
        'Sr.No': 1,
        'ACC Category': 'Design Approval',
        'Brief Detail about Issue': 'Tetting',
        'Affected Milestone': 'Milestone One1',
        'Key Delay Events': 'Yes',
        'Priority': 'Low',
        'Issue Open Date': '19-10-2025',
        'overdue': 0,
        'Delay': '-',
        'Issue close Date': '-',
        'Role': 'Production PMS PC',
        'Attachment': 'No Document',
        'Status Update': 'Pending',
      },
    ];
    accList.value = data.map((e) => AccModel.fromMap(e)).toList();
    isLoading.value = false;
  }

  void searchIssues(String query) {
    if (query.isEmpty) {
      fetchAcc();
    } else {
      accList.value = accList.where((issue) {
        return issue.accCategory.toLowerCase().contains(query.toLowerCase()) ||
            issue.briefDetail.toLowerCase().contains(query.toLowerCase()) ||
            issue.affectedMilestone.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> refreshData() async {
    await fetchAcc();
  }

  // Toggle expanded state for a specific index
  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Collapse if already expanded
    } else {
      expandedIndex.value = index; // Expand the selected card
    }
  }
  
}