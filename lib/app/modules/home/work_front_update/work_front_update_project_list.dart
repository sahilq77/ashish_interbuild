import 'package:ashishinterbuild/app/modules/bottom_navigation/botttom_navigation_controller.dart'
    show BottomNavigationController;
import 'package:ashishinterbuild/app/modules/bottom_navigation/cutom_bottom_bar.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class WorkFrontUpdateProjectList extends StatelessWidget {
  const WorkFrontUpdateProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the same controller instance across all screens
    final ProjectNameController controller = Get.find<ProjectNameController>();
    final bottomController = Get.put(BottomNavigationController());
    ResponsiveHelper.init(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          bool shouldPop = await bottomController.onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppbar(),
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: Column(
            children: [
              // Search + Sort Row
              Padding(
                padding: ResponsiveHelper.padding(16),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchField(controller)),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    _buildSortButton(controller),
                  ],
                ),
              ),

              // Project List
              Expanded(
                child: Obx(() {
                  // First load shimmer
                  if (controller.isLoading.value &&
                      controller.projects.isEmpty) {
                    return _buildShimmerEffect();
                  }

                  // Error state
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: ResponsiveHelper.padding(20),
                        child: Text(
                          controller.errorMessage.value,
                          style: AppStyle.bodyBoldPoppinsBlack.responsive,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Empty state
                  if (controller.projects.isEmpty) {
                    return Center(
                      child: Text(
                        'No projects found',
                        style: AppStyle.bodyBoldPoppinsBlack.responsive,
                      ),
                    );
                  }

                  // List with Load More
                  return ListView.builder(
                    padding: ResponsiveHelper.padding(16),
                    itemCount:
                        controller.projects.length +
                        (controller.hasMoreData.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Load more trigger
                      if (index == controller.projects.length) {
                        controller.loadMore(context);
                        return _buildLoadMoreIndicator(controller);
                      }

                      final project = controller.projects[index];

                      return GestureDetector(
                        onTap: () => Get.toNamed(
                          AppRoutes.workFrontUpdatePackageList,
                          arguments: project.projectId,
                        ),
                        child: Card(
                          margin: EdgeInsets.only(
                            bottom: ResponsiveHelper.screenHeight * 0.02,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              // border: Border(
                              //   left: BorderSide(
                              //     color: AppColors.primary,
                              //     width: 5,
                              //   ),
                              // ),
                            ),
                            child: Padding(
                              padding: ResponsiveHelper.padding(16),
                              child: _buildDetailRow(
                                "Project Name",
                                project.projectName,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  // ── Search Field ─────────────────────────────────────────────────────
  Widget _buildSearchField(ProjectNameController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search projects...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: const Icon(Icons.search, size: 20),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing(12),
          vertical: ResponsiveHelper.spacing(12),
        ),
      ),
      onChanged: controller.searchProjects,
    );
  }

  // ── Sort Button ──────────────────────────────────────────────────────
  Widget _buildSortButton(ProjectNameController controller) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(
            controller.isAscending.value
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: AppColors.primary,
          ),
          onPressed: controller.toggleSorting,
          padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  // ── Project Row ──────────────────────────────────────────────────────
  Widget _buildDetailRow(String label, String value) {
    return Text(
      value,
      style: AppStyle.reportCardTitle.responsive.copyWith(
        fontSize: ResponsiveHelper.getResponsiveFontSize(14),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ── Shimmer Loading ──────────────────────────────────────────────────
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: EdgeInsets.only(
              bottom: ResponsiveHelper.screenHeight * 0.02,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Load More Indicator ──────────────────────────────────────────────
  Widget _buildLoadMoreIndicator(ProjectNameController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Obx(
          () => controller.isLoadingMore.value
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────
  AppBar _buildAppbar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'WFU Project List',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
