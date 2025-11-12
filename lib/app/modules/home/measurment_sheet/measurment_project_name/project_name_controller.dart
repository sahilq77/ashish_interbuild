import 'dart:developer';

import 'package:ashishinterbuild/app/data/models/project_name/get_project_name_response.dart';
import 'package:ashishinterbuild/app/data/models/project_name/project%20_name_model.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/network_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart'
    show AppSnackbarStyles;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ProjectNameController extends GetxController {
  // ── Existing ─────────────────────────────────────────────────────
  final RxList<ProjectName> projects = <ProjectName>[].obs;
  final RxList<ProjectName> filteredProjects = <ProjectName>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxnString selectedProjectFilter = RxnString(null);
  final RxBool isAscending = true.obs;

  // ── New (pagination) ───────────────────────────────────────────
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt offset = 0.obs;
  final int limit = 20; // change to whatever your API expects
  final RxList<ProjectName> projectList = <ProjectName>[].obs; // internal list
  @override
  void onInit() {
    super.onInit();
    fetchProjects(reset: true, context: Get.context!); // first page
    filteredProjects.assignAll(projects); // keep UI in sync
  }

  @override
  void onClose() {
    // Dispose of the search controller
    searchController.dispose();
    super.onClose();
  }

  /// -----------------------------------------------------------
  ///  Fetch projects from the real API
  /// -----------------------------------------------------------
  Future<void> fetchProjects({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    // ---- reset ------------------------------------------------
    if (reset) {
      offset.value = 0;
      projectList.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !reset) {
      log('No more data to fetch');
      return;
    }

    // ---- loading state ----------------------------------------
    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      // ---- API CALL -------------------------------------------
      final response =
          await Networkcall().getMethod(
                Networkutility
                    .getProjectNameListApi, // <-- your endpoint constant
                Networkutility.getProjectNameList, // <-- query-params if any
                context,
              )
              as List<GetProjectNameResponse>?;

      // ---- SUCCESS --------------------------------------------
      if (response != null && response.isNotEmpty) {
        final apiResponse = response[0];

        if (apiResponse.status == true) {
          final List<ProjectData> apiData = apiResponse.data;

          // stop pagination if we got less than limit
          if (apiData.isEmpty || apiData.length < limit) {
            hasMoreData.value = false;
          }

          // ---- Convert API model → UI model --------------------
          final List<ProjectName> newProjects = apiData.map((p) {
            return ProjectName(
              projectId: p.projectId,
              projectName: p.projectName,
              clientName: p.clientName,
              location: "", // API does not return location
              status: p.projectRoles, // you can map to a better field
            );
          }).toList();

          projectList.addAll(newProjects);
          projects.assignAll(projectList); // UI list
          filteredProjects.assignAll(projectList); // filtered list

          offset.value += limit;
          log(
            'Fetched ${newProjects.length} projects – offset: ${offset.value}',
          );
        } else {
          // ---- API returned status:false -----------------------
          hasMoreData.value = false;
          errorMessage.value = apiResponse.message ?? 'No data';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: errorMessage.value,
          );
        }
      } else {
        // ---- No response ---------------------------------------
        hasMoreData.value = false;
        errorMessage.value = 'Empty response';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    }
    // ---- EXCEPTIONS -------------------------------------------
    on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
  // Function to load dummy data

  // Function to handle refresh
  Future<void> refreshData() async {
    searchController.clear();
    selectedProjectFilter.value = null;
    await fetchProjects(reset: true, context: Get.context!);
  }

  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchProjects(context: context, isPagination: true);
    }
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
        projects
            .where(
              (project) =>
                  project.projectName.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  project.clientName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList(),
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
          .where(
            (p) =>
                p.projectName.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                p.clientName.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ),
          )
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
