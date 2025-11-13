import 'dart:async';
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
  // ── UI State ─────────────────────────────────────────────────────
  final RxList<ProjectName> projects = <ProjectName>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // ── Pagination ───────────────────────────────────────────────────
  final RxInt offset = 0.obs;
  final int limit = 20;

  // ── Internal API Params ─────────────────────────────────────────
  final RxString _currentKeyword = ''.obs;
  final RxString _currentOrderBy = 'desc'.obs;
  final RxBool isAscending = true.obs; // UI only (icon)

  // ── Debounce ─────────────────────────────────────────────────────
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    _currentOrderBy.value = '';
    isAscending.value = true;
    fetchProjects(reset: true, context: Get.context!, isPagination: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ── Build Query String ───────────────────────────────────────────
  String _buildQueryParams({bool includePagination = true}) {
    final List<String> parts = [];

    if (_currentKeyword.value.isNotEmpty) {
      parts.add('keyword=${Uri.encodeComponent(_currentKeyword.value)}');
    }

    parts.add('order_by=${_currentOrderBy.value}');

    if (includePagination) {
      parts.add('start=${offset.value}');
      parts.add('length=$limit');
    }

    return parts.isNotEmpty ? '?${parts.join('&')}' : '';
  }

  // ── Fetch Projects (with keyword, order_by, pagination) ──────────
  Future<void> fetchProjects({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
  }) async {
    projects.clear();
    if (reset) {
      offset.value = 0;
      projects.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !reset) {
      log('No more data');
      return;
    }

    if (isPagination) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final String query = _buildQueryParams();
      final String endpoint = Networkutility.getProjectNameList + query;

      log('API → $endpoint');

      final response =
          await Networkcall().getMethod(
                Networkutility.getProjectNameListApi,
                endpoint,
                context,
              )
              as List<GetProjectNameResponse>?;

      if (response != null && response.isNotEmpty) {
        final apiResponse = response[0];

        if (apiResponse.status == true) {
          final List<ProjectData> apiData = apiResponse.data;

          if (apiData.isEmpty || apiData.length < limit) {
            hasMoreData.value = false;
          }

          final List<ProjectName> newProjects = apiData.map((p) {
            return ProjectName(
              projectId: p.projectId,
              projectName: p.projectName,
              clientName: p.clientName,
              location: "",
              status: p.projectRoles,
            );
          }).toList();

          if (reset) {
            projects.assignAll(newProjects);
          } else {
            projects.addAll(newProjects);
          }

          offset.value += limit;

          log('Fetched ${newProjects.length} | Total: ${projects.length}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = apiResponse.message ?? 'No data';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: errorMessage.value,
          );
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'Empty response';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: errorMessage.value,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ── Search (Debounced) ───────────────────────────────────────────
  void searchProjects(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      if (_currentKeyword.value != trimmed) {
        _currentKeyword.value = trimmed;
        fetchProjects(reset: true, context: Get.context!);
      }
    });
  }

  // ── Toggle Sorting ───────────────────────────────────────────────
  void toggleSorting() {
    isAscending.value = !isAscending.value;
    _currentOrderBy.value = isAscending.value ? 'desc' : 'asc';
    fetchProjects(reset: true, context: Get.context!);
    update();
  }

  // ── Load More ────────────────────────────────────────────────────
  void loadMore(BuildContext context) {
    if (!isLoadingMore.value && hasMoreData.value) {
      fetchProjects(context: context, isPagination: true);
    }
  }

  // ── Refresh ──────────────────────────────────────────────────────
  Future<void> refreshData() async {
    searchController.clear();
    _currentKeyword.value = '';
    _currentOrderBy.value = '';
    isAscending.value = true;
    await fetchProjects(reset: true, context: Get.context!);
  }

  // ── View Project (Optional) ──────────────────────────────────────
  void viewProject(ProjectName project) {
    log('View: ${project.projectName} (ID: ${project.projectId})');
    // Navigate or show dialog
  }
}
