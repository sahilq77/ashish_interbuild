import 'package:ashishinterbuild/app/data/models/project_name/project%20_name_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';


class MeasurmentProjectNameController extends GetxController {
  // Reactive list of projects
  final RxList<ProjectName> projects = <ProjectName>[].obs;

  // Reactive list for filtered projects
  final RxList<ProjectName> filteredProjects = <ProjectName>[].obs;

  // Reactive variable to track loading state
  final RxBool isLoading = true.obs;

  // TextEditingController for the search field
  final TextEditingController searchController = TextEditingController();

  // Filter variables
  final RxnString selectedProjectFilter = RxnString(null);

  // Sorting variables
  final RxBool isAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Load dummy data when controller is initialized
    loadDummyData();
    // Initialize filtered list with all projects
    filteredProjects.assignAll(projects);
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
    projects.assignAll([
      ProjectName(
        projectId: "PRJ001",
        projectName: "Skyline Towers",
        clientName: "ABC Corp",
        location: "New York",
        status: "In Progress",
      ),
      ProjectName(
        projectId: "PRJ002",
        projectName: "Green Valley",
        clientName: "XYZ Ltd",
        location: "California",
        status: "Completed",
      ),
      ProjectName(
        projectId: "PRJ003",
        projectName: "Urban Hub",
        clientName: "DEF Inc",
        location: "Chicago",
        status: "Planning",
      ),
    ]);
    // Update filtered list after loading data
    filteredProjects.assignAll(projects);
    isLoading.value = false;
  }

  // Function to handle refresh
  Future<void> refreshData() async {
    isLoading.value = true;
    // Clear existing data
    projects.clear();
    filteredProjects.clear();
    // Simulate network delay and reload data
    await Future.delayed(Duration(seconds: 2));
    await loadDummyData();
    // Reset search
    searchController.clear();
  }

  // Function to handle view action
  void viewProject(ProjectName project) {
    // Implement navigation or dialog to view details
    print('Viewing: ${project.projectName}');
  }

  // Function to handle search
  void searchProjects(String query) {
    if (query.isEmpty) {
      // If search query is empty, show all projects
      filteredProjects.assignAll(projects);
    } else {
      // Filter projects based on projectName or clientName
      filteredProjects.assignAll(
        projects.where(
          (project) =>
              project.projectName.toLowerCase().contains(query.toLowerCase()) ||
              project.clientName.toLowerCase().contains(query.toLowerCase()),
        ).toList(),
      );
    }
    applySorting();
  }

  // Get unique project names for filter
  List<String> getProjectNames() {
    return projects.map((p) => p.projectName).toSet().toList();
  }

  // Apply filters
  void applyFilters() {
    var filtered = projects.toList();

    if (selectedProjectFilter.value != null) {
      filtered = filtered
          .where((p) => p.projectName == selectedProjectFilter.value)
          .toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.projectName
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              p.clientName
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
          .toList();
    }

    filteredProjects.assignAll(filtered);
    applySorting();
  }

  // Clear filters
  void clearFilters() {
    selectedProjectFilter.value = null;
    searchController.clear();
    filteredProjects.assignAll(projects);
    applySorting();
  }

  // Toggle sorting
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    applySorting();
  }

  // Apply sorting
  void applySorting() {
    if (isAscending.value) {
      filteredProjects.sort((a, b) => a.projectName.compareTo(b.projectName));
    } else {
      filteredProjects.sort((a, b) => b.projectName.compareTo(a.projectName));
    }
  }
}