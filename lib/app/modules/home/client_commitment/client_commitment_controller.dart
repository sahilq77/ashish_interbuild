import 'package:ashishinterbuild/app/data/models/client_commitment/client_commitment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientCommitmentController extends GetxController {
  // ──────────────────────────────────────────────────────────────
  // Observables
  // ──────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxInt expandedIndex = (-1).obs;
  final RxList<ClientCommitmentModel> commitmentList = <ClientCommitmentModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  // Filter Observables
  final RxString selectedRole = ''.obs;
  final RxString selectedHod = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedMilestone = ''.obs;
  final RxString selectedPriority = ''.obs;
  final RxString selectedIssueOpen = ''.obs;

  // Sorting
  final RxBool isAscending = true.obs;
  final RxString sortField = 'srNo'.obs;

  // Original list to preserve data on filter reset
  final RxList<ClientCommitmentModel> _originalList = <ClientCommitmentModel>[].obs;

  // ──────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ──────────────────────────────────────────────────────────────
  // Data Fetching
  // ──────────────────────────────────────────────────────────────
  Future<void> fetchData() async {
    isLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API

      final List<ClientCommitmentModel> data = [
        ClientCommitmentModel(
          srNo: 1,
          taskAssignedTo: "Savant Akash",
          hod: "Tester",
          taskDetails: "Design review pending",
          affectedMilestone: "Milestone One",
          priority: "High",
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
        ClientCommitmentModel(
          srNo: 2,
          taskAssignedTo: "John Doe",
          hod: "Manager",
          taskDetails: "Finance approval required",
          affectedMilestone: "Milestone Two",
          priority: "Medium",
          milestoneTargetDate: DateTime(2025, 11, 1),
          initialTargetDate: DateTime(2025, 11, 5),
          ccCategory: "Finance Approval",
          overdueDays: 3,
          delay: "2 days",
          revisedCompletionDate: DateTime(2025, 11, 7),
          closeDate: null,
          statusUpdate: "In Progress",
          attachment: "View",
          remark: "Waiting for client",
        ),
        ClientCommitmentModel(
          srNo: 3,
          taskAssignedTo: "Alice Smith",
          hod: "Director",
          taskDetails: "Final sign-off",
          affectedMilestone: "Milestone One",
          priority: "Low",
          milestoneTargetDate: DateTime(2025, 10, 20),
          initialTargetDate: DateTime(2025, 10, 22),
          ccCategory: "Legal Approval",
          overdueDays: 0,
          delay: "-",
          revisedCompletionDate: null,
          closeDate: DateTime(2025, 10, 21),
          statusUpdate: "Closed",
          attachment: "View",
          remark: "Approved",
        ),
        ClientCommitmentModel(
          srNo: 4,
          taskAssignedTo: "Savant Akash",
          hod: "Tester",
          taskDetails: "Testing phase 2",
          affectedMilestone: "Milestone Three",
          priority: "High",
          milestoneTargetDate: DateTime(2025, 12, 1),
          initialTargetDate: DateTime(2025, 12, 5),
          ccCategory: "Testing Clearance",
          overdueDays: 5,
          delay: "3 days",
          revisedCompletionDate: DateTime(2025, 12, 8),
          closeDate: null,
          statusUpdate: "Delayed",
          attachment: "View",
          remark: "Client feedback pending",
        ),
      ];

      _originalList.assignAll(data);
      commitmentList.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async => await fetchData();

  // ──────────────────────────────────────────────────────────────
  // Expand / Collapse
  // ──────────────────────────────────────────────────────────────
  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  // ──────────────────────────────────────────────────────────────
  // Search
  // ──────────────────────────────────────────────────────────────
  void searchCommitments(String query) {
    _applyAllFilters(searchQuery: query.trim());
  }

  // ──────────────────────────────────────────────────────────────
  // Sorting
  // ──────────────────────────────────────────────────────────────
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    applyFilters();
  }

  void setSortField(String field) {
    if (sortField.value == field) {
      toggleSorting();
    } else {
      sortField.value = field;
      isAscending.value = true;
      applyFilters();
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Filter & Sort Pipeline
  // ──────────────────────────────────────────────────────────────
  void _applyAllFilters({String searchQuery = ''}) {
    List<ClientCommitmentModel> filtered = _originalList.toList();

    // ── SEARCH ───────────────────────────────────────────────
    if (searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.taskDetails.toLowerCase().contains(lowerQuery) ||
            item.taskAssignedTo.toLowerCase().contains(lowerQuery) ||
            item.affectedMilestone.toLowerCase().contains(lowerQuery) ||
            item.ccCategory.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // ── FILTERS ──────────────────────────────────────────────
    if (selectedRole.value.isNotEmpty) {
      filtered = filtered.where((e) => e.taskAssignedTo == selectedRole.value).toList();
    }
    if (selectedHod.value.isNotEmpty) {
      filtered = filtered.where((e) => e.hod == selectedHod.value).toList();
    }
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((e) => e.ccCategory == selectedCategory.value).toList();
    }
    if (selectedMilestone.value.isNotEmpty) {
      filtered = filtered.where((e) => e.affectedMilestone == selectedMilestone.value).toList();
    }
    if (selectedPriority.value.isNotEmpty) {
      filtered = filtered.where((e) => (e.priority ?? '-') == selectedPriority.value).toList();
    }
    if (selectedIssueOpen.value.isNotEmpty) {
      final bool wantOpen = selectedIssueOpen.value == 'Yes';
      filtered = filtered.where((e) => (e.closeDate == null) == wantOpen).toList();
    }

    // ── SORTING ──────────────────────────────────────────────
    filtered.sort((a, b) {
      int cmp = 0;

      switch (sortField.value) {
        case 'srNo':
          cmp = a.srNo.compareTo(b.srNo);
          break;
        case 'taskAssignedTo':
          cmp = a.taskAssignedTo.compareTo(b.taskAssignedTo);
          break;
        case 'hod':
          cmp = a.hod.compareTo(b.hod);
          break;
        case 'affectedMilestone':
          cmp = a.affectedMilestone.compareTo(b.affectedMilestone);
          break;
        case 'priority':
          cmp = (a.priority ?? '-').compareTo(b.priority ?? '-');
          break;
        case 'overdueDays':
          cmp = a.overdueDays.compareTo(b.overdueDays);
          break;
        case 'milestoneTargetDate':
          cmp = a.milestoneTargetDate.compareTo(b.milestoneTargetDate);
          break;
        case 'closeDate':
          final dateA = a.closeDate;
          final dateB = b.closeDate;
          if (dateA == null && dateB == null) cmp = 0;
          else if (dateA == null) cmp = -1;
          else if (dateB == null) cmp = 1;
          else cmp = dateA.compareTo(dateB);
          break;
        default:
          cmp = a.srNo.compareTo(b.srNo);
      }

      return isAscending.value ? cmp : -cmp;
    });

    commitmentList.assignAll(filtered);
  }

  // Public method called from UI (Apply button in dialog)
  void applyFilters() {
    _applyAllFilters(searchQuery: searchController.text.trim());
  }

  // ──────────────────────────────────────────────────────────────
  // Clear All Filters
  // ──────────────────────────────────────────────────────────────
  void clearFilters() {
    selectedRole.value = '';
    selectedHod.value = '';
    selectedCategory.value = '';
    selectedMilestone.value = '';
    selectedPriority.value = '';
    selectedIssueOpen.value = '';
    searchController.clear();
    sortField.value = 'srNo';
    isAscending.value = true;
    commitmentList.assignAll(_originalList);
  }

  // ──────────────────────────────────────────────────────────────
  // Dropdown Data Getters
  // ──────────────────────────────────────────────────────────────
  List<String> get roleList =>
      _originalList.map((e) => e.taskAssignedTo).toSet().toList()..sort();

  List<String> get hodList =>
      _originalList.map((e) => e.hod).toSet().toList()..sort();

  List<String> get categoryList =>
      _originalList.map((e) => e.ccCategory).toSet().toList()..sort();

  List<String> get milestoneList =>
      _originalList.map((e) => e.affectedMilestone).toSet().toList()..sort();

  List<String> get priorityList => _originalList
      .map((e) => e.priority ?? '-')
      .where((e) => e != '-')
      .toSet()
      .toList()
    ..sort();
}