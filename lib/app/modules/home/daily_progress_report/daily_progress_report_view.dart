import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
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

class DailyProgressReportViiew extends StatelessWidget {
  const DailyProgressReportViiew({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyProgressReportController controller = Get.find();
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 16, left: 16, right: 16),
              child: Text(
                "Skyline Towers ➔ DPR Dashboard ➔ DPR",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
            ),
            // Add search field
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
                    : controller.errorMessage.value.isNotEmpty
                        ? Center(
                            child: Text(
                              controller.errorMessage.value,
                              style: AppStyle.bodyBoldPoppinsBlack.responsive,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : controller.filteredMeasurementSheets.isEmpty
                            ? const Center(child: Text('No data found'))
                            : ListView.builder(
                        padding: ResponsiveHelper.padding(16),
                        itemCount: controller.filteredMeasurementSheets.length +
                            (controller.hasMoreData.value || controller.isLoadingMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= controller.filteredMeasurementSheets.length) {
                            if (controller.hasMoreData.value && !controller.isLoadingMore.value) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.loadMore(context);
                              });
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: controller.hasMoreData.value
                                    ? const CircularProgressIndicator()
                                    : Text('No more data', style: TextStyle(color: AppColors.grey)),
                              ),
                            );
                          }
                          
                          final sheet = controller.filteredMeasurementSheets[index];
                          return GestureDetector(
                            onTap: () => controller.toggleExpanded(index),
                            child: Obx(() {
                              final isExpanded = controller.expandedIndex.value == index;
                              return Card(
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
                                    child: Column(
                                      children: [
                                        if (controller.getFrontDisplayColumns().isNotEmpty)
                                          ...controller.getFrontDisplayColumns().take(1).map((col) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: _buildDetailRow(col, controller.getFieldValue(sheet, col)),
                                            );
                                          }).toList(),
                                        // _buildDetailRow(
                                        //   "Package Name",
                                        //   sheet.packageName,
                                        // ),

                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        // _buildDetailRow(
                                        //   "PBOQ Name",
                                        //   sheet.pboqName,
                                        // ),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        // _buildDetailRow("PBOA", sheet.pboa),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        // _buildDetailRow(
                                        //   "Today\`s Target PBOA Qty",
                                        //   sheet.todaysTargetPboaQuantity,
                                        // ),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        // _buildDetailRow(
                                        //   "Today\`s Achieve Qty",
                                        //   sheet.todaysAchieveQuantity,
                                        // ),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        if (isExpanded && controller.appColumnDetails.value.columns.isNotEmpty) ...[
                                          ...controller.appColumnDetails.value.columns
                                              .where((col) => !controller.getFrontDisplayColumns().contains(col))
                                              .map((col) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 6),
                                                    child: _buildDetailRow(col, controller.getFieldValue(sheet, col)),
                                                  ))
                                              .toList(),
                                        ],
                                        SizedBox(
                                          height:
                                              ResponsiveHelper.screenHeight *
                                              0.01,
                                        ),
                                        //  Divider(),
                                        Row(
                                          children: [
                                            if (controller.getFrontSecondaryDisplayColumns().isNotEmpty)
                                              ...controller.getFrontSecondaryDisplayColumns().map((col) {
                                                return Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(bottom: 6),
                                                    child: Text(
                                                      "$col: ${controller.getFieldValue(sheet, col)}",
                                                      style: AppStyle.labelPrimaryPoppinsBlack.responsive.copyWith(fontSize: 13),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            const SizedBox(width: 8),
                                            if (controller.getButtonDisplayColumns().isNotEmpty)
                                              ...controller.getButtonDisplayColumns().map((col) {
                                                return Expanded(
                                                  child: OutlinedButton(
                                                    style: AppButtonStyles.outlinedExtraSmallPrimary(),
                                                    onPressed: () {
                                                      Get.toNamed(AppRoutes.updateDailyReportList);
                                                    },
                                                    child: Text(
                                                      "$col: ${controller.getFieldValue(sheet, col)}",
                                                      style: AppStyle.labelPrimaryPoppinsBlack.responsive.copyWith(fontSize: 10),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            // Expanded(
                                            //   child: ElevatedButton(
                                            //     style:
                                            //         AppButtonStyles.elevatedSmallBlack(),
                                            //     onPressed: () {
                                            //       controller.toggleExpanded(
                                            //         index,
                                            //       );
                                            //     },
                                            //     child: Text(
                                            //       controller
                                            //                   .expandedIndex
                                            //                   .value ==
                                            //               index
                                            //           ? "Less"
                                            //           : "Read",
                                            //       style: AppStyle
                                            //           .labelPrimaryPoppinsWhite,
                                            //     ),
                                            //   ),
                                            // ),
                                            // SizedBox(
                                            //   width:
                                            //       ResponsiveHelper.screenWidth *
                                            //       0.05,
                                            // ),
                                            // Expanded(
                                            //   child: OutlinedButton(
                                            //     style:
                                            //         AppButtonStyles.outlinedSmallBlack(),
                                            //     onPressed: () {
                                            //       Get.toNamed(
                                            //         AppRoutes
                                            //             .updateDailyReportList,
                                            //       );
                                            //     },
                                            //     child: Text(
                                            //       "Update",
                                            //       style: AppStyle
                                            //           .labelPrimaryPoppinsBlack,
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildSearchField(DailyProgressReportController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search....',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: controller.searchSurveys,
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
                child: Column(
                  children: [
                    _buildShimmerRow(),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _buildShimmerRow(),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _buildShimmerRow(),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.screenWidth * 0.05),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: AppStyle.reportCardTitle.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(13),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          ': ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyle.reportCardSubTitle,
        ),
        Expanded(
          child: Text(
            value,
            style: AppStyle.reportCardSubTitle.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(13),
            ),
          ),
        ),
      ],
    );
  }

  Text _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.grey,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Daily Progress Report',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    ); AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Daily Progress Report',
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

  // Filter Button
  Widget _buildFilterButton(
    BuildContext context,
    DailyProgressReportController controller,
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

  // Filter Dialog
  void _showFilterDialog(
    BuildContext context,
    DailyProgressReportController controller,
  ) {
    String? tempSelectedPackage = controller.selectedPackageFilter.value;

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
                  'Filter Measurement Sheets',
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
                        labelText: 'Search Package',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  items: controller.getPackageNames(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Package',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        Icons.business,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      tempSelectedPackage = value;
                    });
                  },
                  selectedItem: tempSelectedPackage,
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
                            borderRadius: BorderRadius.circular(10),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          controller.selectedPackageFilter.value =
                              tempSelectedPackage;
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

  // Sort Button
  Widget _buildSortButton(DailyProgressReportController controller) {
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
}
