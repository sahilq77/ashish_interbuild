import 'package:ashishinterbuild/app/modules/bottom_navigation/botttom_navigation_controller.dart'
    show BottomNavigationController;
import 'package:ashishinterbuild/app/modules/bottom_navigation/cutom_bottom_bar.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_project_name/measurment_project_name_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class DprProjectList extends StatelessWidget {
  const DprProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    final MeasurmentProjectNameController controller = Get.find();
    final bottomController = Get.put(BottomNavigationController());
    ResponsiveHelper.init(context);
    return PopScope(
      canPop: false, // Prevent default back navigation
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Call the same onWillPop logic from BottomNavigationController
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
              // Search, Filter and Sort row
              Padding(
                padding: ResponsiveHelper.padding(16),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchField(controller)),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    _buildFilterButton(context, controller),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    _buildSortButton(controller),
                  ],
                ),
              ),
              // Expanded to make ListView take remaining space
              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? _buildShimmerEffect(context)
                      : ListView.builder(
                          padding: ResponsiveHelper.padding(16),
                          itemCount: controller.filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = controller.filteredProjects[index];
                            return GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.dailyProgressDashboard),
                              child: Card(
                                margin: EdgeInsets.only(
                                  bottom: ResponsiveHelper.screenHeight * 0.02,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey.shade50,
                                      ],
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
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }

  Widget _buildSearchField(MeasurmentProjectNameController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search, size: 20),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing(12),
          vertical: ResponsiveHelper.spacing(12),
        ),
      ),
      onChanged: controller.searchProjects,
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    MeasurmentProjectNameController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: AppColors.primary),
        onPressed: () => _showFilterDialog(context, controller),
        padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildSortButton(MeasurmentProjectNameController controller) {
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

  void _showFilterDialog(
    BuildContext context,
    MeasurmentProjectNameController controller,
  ) {
    String? tempSelectedProject = controller.selectedProjectFilter.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.paddingSymmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ResponsiveHelper.spacing(20)),
                  ),
                ),
                child: Text(
                  'Filter Projects',
                  style: AppStyle.heading1PoppinsWhite.responsive,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: ResponsiveHelper.padding(20),
                child: DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'Search Project',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  items: controller.getProjectNames(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Project',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.spacing(8),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.spacing(8),
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.business,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      tempSelectedProject = value;
                    });
                  },
                  selectedItem: tempSelectedProject,
                ),
              ),
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: ResponsiveHelper.paddingSymmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.spacing(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          controller.clearFilters();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear',
                          style: AppStyle.labelPrimaryPoppinsBlack.responsive,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(16)),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: ResponsiveHelper.paddingSymmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.spacing(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          controller.selectedProjectFilter.value =
                              tempSelectedProject;
                          controller.applyFilters();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Apply',
                          style: AppStyle.labelPrimaryPoppinsWhite.responsive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 5, // Show 5 shimmer cards
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: EdgeInsets.only(
              bottom: ResponsiveHelper.screenHeight * 0.02,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 5),
                ),
              ),
              child: Padding(
                padding: ResponsiveHelper.padding(16),
                child: Column(children: [_buildShimmerRow()]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 130, height: 16, color: Colors.grey.shade300),
        const SizedBox(width: 8),
        Text(': ', style: AppStyle.reportCardSubTitle),
        Expanded(child: Container(height: 16, color: Colors.grey.shade300)),
      ],
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
        'DPR Project List',
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
