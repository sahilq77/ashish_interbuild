import 'package:ashishinterbuild/app/modules/bottom_navigation/botttom_navigation_controller.dart'
    show BottomNavigationController;
import 'package:ashishinterbuild/app/modules/bottom_navigation/cutom_bottom_bar.dart';
import 'package:ashishinterbuild/app/modules/global_controller/package/package_list_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/project_name/project_name_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MesurmentPackageList extends StatelessWidget {
  const MesurmentPackageList({super.key});

  @override
  Widget build(BuildContext context) {
    final PackageListController controller = Get.find();

    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          children: [
            // ── Search + Sort Row ─────────────────────────────────────
            Padding(
              padding: ResponsiveHelper.padding(16),
              child: Row(
                children: [
                  Expanded(child: _buildSearchField(controller)),
                  SizedBox(width: ResponsiveHelper.spacing(8)),
                  // _buildFilterButton(context, controller), // optional
                  // SizedBox(width: ResponsiveHelper.spacing(8)),
                  _buildSortButton(controller),
                ],
              ),
            ),

            // ── Error Message (if any) ───────────────────────────────
            Obx(() => controller.errorMessage.value.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: ResponsiveHelper.padding(12),
                    margin: ResponsiveHelper.padding(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : const SizedBox.shrink()),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                // Initial loading
                if (controller.isLoading.value && controller.packages.isEmpty) {
                  return _buildShimmerEffect(context);
                }

                // Empty state
                if (controller.filteredPackages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: ResponsiveHelper.padding(16),
                  itemCount: controller.filteredPackages.length +
                      (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // ── Load More Trigger ─────────────────────────────
                    if (index == controller.filteredPackages.length) {
                      // Auto-load more when reaching bottom
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.loadMore(context);
                      });

                      return _buildLoadMoreIndicator();
                    }

                    final package = controller.filteredPackages[index];

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.measurmentSheetView,
                          arguments: {
                            "project_id": int.parse(package.projectId),
                            "package_id": int.parse(package.packageId),
                          },
                        );
                      },
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
                          ),
                          child: Padding(
                            padding: ResponsiveHelper.padding(16),
                            child: _buildDetailRow(
                              "Package",
                              package.packageName,
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
    );
  }

  // ────────────────────────────────────────────────────────────────
  // UI Components
  // ────────────────────────────────────────────────────────────────

  Widget _buildSearchField(PackageListController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search packages...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search, size: 20),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing(12),
          vertical: ResponsiveHelper.spacing(12),
        ),
      ),
      onChanged: controller.searchPackages,
    );
  }

  Widget _buildSortButton(PackageListController controller) {
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

  // Optional: Keep filter dropdown (client-side)


 

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No packages found',
            style: AppStyle.heading2PoppinsGrey.responsive,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppStyle.bodyBoldPoppinsBlack.responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.screenHeight * 0.02),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Text(
      value,
      style: AppStyle.reportCardTitle.responsive.copyWith(
        fontSize: ResponsiveHelper.getResponsiveFontSize(14),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Measurement Package List',
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