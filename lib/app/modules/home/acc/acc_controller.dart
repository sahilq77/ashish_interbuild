import 'package:ashishinterbuild/app/data/models/acc/acc_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccController extends GetxController {
  var isLoading = true.obs;
  var accList = <AccModel>[].obs;
  final searchController = TextEditingController();
  var expandedIndex = (-1).obs;

  // ────── FILTERS ──────
  var selectedCategoryFilter = Rxn<String>();
  var selectedRoleFilter = Rxn<String>();

  // ────── NEW FILTERS (ADDED) ──────
  var selectedPackageFilter = Rxn<String>();
  var selectedPriorityFilter = Rxn<String>();
  var selectedMilestoneFilter = Rxn<String>();
  var selectedKeyDelayFilter = Rxn<String>(); // "Yes" / "No"

  // ────── ORIGINAL LIST ──────
  var _originalList = <AccModel>[].obs;

  // ────── SORTING ──────
  var isAscending = true.obs;
  var sortBy = 'Sr.No'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAcc();
  }

  // ────────────────────── FETCH DATA ──────────────────────
  Future<void> fetchAcc() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    var data = [
      {
        'Sr.No': 1,
        'PckageName': 'Silver',
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
      {
        'Sr.No': 2,
        'PckageName': 'Platinum',
        'ACC Category': 'Material Supply',
        'Brief Detail about Issue': 'Steel delayed',
        'Affected Milestone': 'Milestone Two',
        'Key Delay Events': 'No',
        'Priority': 'High',
        'Issue Open Date': '15-10-2025',
        'overdue': 5,
        'Delay': '5 days',
        'Issue close Date': '-',
        'Role': 'Vendor',
        'Attachment': 'Yes',
        'Status Update': 'In Progress',
      },
      {
        'Sr.No': 3,
        'PckageName': 'Gold',
        'ACC Category': 'Design Approval',
        'Brief Detail about Issue': 'Drawing revision',
        'Affected Milestone': 'Milestone One1',
        'Key Delay Events': 'Yes',
        'Priority': 'Medium',
        'Issue Open Date': '10-10-2025',
        'overdue': 10,
        'Delay': '10 days',
        'Issue close Date': '20-10-2025',
        'Role': 'Architect',
        'Attachment': 'Yes',
        'Status Update': 'Closed',
      },
    ];

    final List<AccModel> list = data.map((e) => AccModel.fromMap(e)).toList();
    _originalList.assignAll(list);
    accList.assignAll(list);
    isLoading.value = false;

    _applySort();
  }

  // ────────────────────── SORTING HELPERS ──────────────────────
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _applySort();
  }

  void setSortBy(String field) {
    if (sortBy.value == field) {
      toggleSorting();
    } else {
      sortBy.value = field;
      isAscending.value = true;
      _applySort();
    }
  }

  void _applySort() {
    final List<AccModel> temp = List.from(accList);

    temp.sort((a, b) {
      int compare = 0;

      switch (sortBy.value) {
        case 'Sr.No':
          compare = a.srNo.compareTo(b.srNo);
          break;
        case 'ACC Category':
          compare = a.accCategory.compareTo(b.accCategory);
          break;
        case 'Priority':
          const order = {'High': 0, 'Medium': 1, 'Low': 2};
          int aVal = order[a.priority] ?? 3;
          int bVal = order[b.priority] ?? 3;
          compare = aVal.compareTo(bVal);
          break;
        case 'Issue Open Date':
          compare = _parseDate(a.issueOpenDate).compareTo(_parseDate(b.issueOpenDate));
          break;
        case 'overdue':
          compare = a.overdue.compareTo(b.overdue);
          break;
        default:
          compare = a.srNo.compareTo(b.srNo);
      }

      return isAscending.value ? compare : -compare;
    });

    accList.assignAll(temp);
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return DateTime(1970);
    }
  }

  // ────────────────────── DROPDOWN LISTS (ADDED) ──────────────────────
  List<String> get packageNames =>
      _originalList.map((e) => e.packageName).toSet().toList()..sort();

  List<String> get categoryNames =>
      _originalList.map((e) => e.accCategory).toSet().toList()..sort();

  List<String> get priorityNames =>
      _originalList.map((e) => e.priority).toSet().toList()..sort();

  List<String> get milestoneNames =>
      _originalList.map((e) => e.affectedMilestone).toSet().toList()..sort();

  List<String> get roleNames =>
      _originalList.map((e) => e.role).toSet().toList()..sort();

  List<String> get keyDelayOptions => ['Yes', 'No'];

  // ────────────────────── FILTER HELPERS (UPDATED) ──────────────────────
  void applyFilters() {
    final cat = selectedCategoryFilter.value;
    final role = selectedRoleFilter.value;
    final pkg = selectedPackageFilter.value;
    final pri = selectedPriorityFilter.value;
    final mile = selectedMilestoneFilter.value;
    final key = selectedKeyDelayFilter.value;

    final filtered = _originalList.where((issue) {
      final catOk = cat == null || issue.accCategory == cat;
      final roleOk = role == null || issue.role == role;
      final pkgOk = pkg == null || issue.packageName == pkg;
      final priOk = pri == null || issue.priority == pri;
      final mileOk = mile == null || issue.affectedMilestone == mile;
      final keyOk = key == null ||
          (key == 'Yes' ? issue.keyDelayEvents : !issue.keyDelayEvents);
      return catOk && roleOk && pkgOk && priOk && mileOk && keyOk;
    }).toList();

    accList.assignAll(filtered);
    _applySort();
  }

  void clearFilters() {
    selectedCategoryFilter.value = null;
    selectedRoleFilter.value = null;
    selectedPackageFilter.value = null;
    selectedPriorityFilter.value = null;
    selectedMilestoneFilter.value = null;
    selectedKeyDelayFilter.value = null;

    accList.assignAll(_originalList);
    _applySort();
  }

  // ────────────────────── SEARCH (UNCHANGED) ──────────────────────
  void searchIssues(String query) {
    final base = (selectedCategoryFilter.value != null ||
            selectedRoleFilter.value != null ||
            selectedPackageFilter.value != null ||
            selectedPriorityFilter.value != null ||
            selectedMilestoneFilter.value != null ||
            selectedKeyDelayFilter.value != null)
        ? _originalList
        : _originalList;

    List<AccModel> result = base;

    if (query.isNotEmpty) {
      result = result.where((issue) {
        return issue.accCategory.toLowerCase().contains(query.toLowerCase()) ||
            issue.briefDetail.toLowerCase().contains(query.toLowerCase()) ||
            issue.affectedMilestone.toLowerCase().contains(query.toLowerCase()) ||
            issue.packageName.toLowerCase().contains(query.toLowerCase()) ||
            issue.role.toLowerCase().contains(query.toLowerCase()) ||
            issue.priority.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    accList.assignAll(result);
    _applySort();
  }

  // ────────────────────── REFRESH ──────────────────────
  Future<void> refreshData() async => await fetchAcc();

  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }
}