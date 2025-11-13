import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dropdown_search/dropdown_search.dart'; // Add this import

class MeasurmentSheetView extends StatelessWidget {
  const MeasurmentSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final MeasurementSheetController controller = Get.find();
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(controller),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 16, left: 16, right: 16),
              child: Text(
                "Skyline Towers ➔ Measurement Sheet",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
            ),

            // Search, Filter, and Sort Row
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

            // Expanded ListView
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? _buildShimmerEffect(context)
                    : ListView.builder(
                        padding: ResponsiveHelper.padding(16),
                        itemCount: controller.filteredMeasurementSheets.length,
                        itemBuilder: (context, index) {
                          final sheet =
                              controller.filteredMeasurementSheets[index];
                          return GestureDetector(
                            onTap: () {
                              controller.toggleExpanded(index);
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
                                  // border: Border(
                                  //   left: BorderSide(
                                  //     color: AppColors.primary,
                                  //     width: 5,
                                  //   ),
                                  // ),
                                ),
                                child: Obx(
                                  () => Padding(
                                    padding: ResponsiveHelper.padding(16),
                                    child: Column(
                                      children: [
                                        // _buildDetailRow(
                                        //   "Package Name",
                                        //   sheet.packageName,
                                        // ),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        _buildDetailRow(
                                          "CBOQ Name",
                                          sheet.cboqName,
                                        ),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        // _buildDetailRow("MS Qty", sheet.msQty),
                                        if (controller.expandedIndex.value ==
                                            index) ...[
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "PBOQ Name",
                                            sheet.pboqName,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow("Zones", sheet.zones),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow("UOM", sheet.uom),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "PBOQ Qty",
                                            sheet.pboqQty,
                                          ),
                                        ],
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.01,
                                        // ),
                                        // Divider(),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                textAlign: TextAlign.start,
                                                "Qty: ${sheet.msQty}",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsBlack
                                                    .responsive
                                                    .copyWith(fontSize: 13),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                                  ResponsiveHelper.screenWidth *
                                                  0.01,
                                            ),
                                            Expanded(
                                              child: Text(
                                                textAlign: TextAlign.start,
                                                "Amt: ${sheet.msQty}" + "00000",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsBlack
                                                    .responsive
                                                    .copyWith(fontSize: 13),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                                  ResponsiveHelper.screenWidth *
                                                  0.01,
                                            ),
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallPrimary(),
                                                onPressed: () {
                                                  Get.toNamed(
                                                    AppRoutes.pboqList,
                                                  );
                                                },
                                                child: Text(
                                                  "Ms Qty: ${sheet.msQty}",
                                                  style: AppStyle
                                                      .labelPrimaryPoppinsBlack
                                                      .responsive
                                                      .copyWith(fontSize: 10),
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
                            ),
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

  // Search Field
  TextFormField _buildSearchField(MeasurementSheetController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search....',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: controller.searchSurveys,
    );
  }

  // Filter Button
  Widget _buildFilterButton(
    BuildContext context,
    MeasurementSheetController controller,
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

  // Sort Button
  Widget _buildSortButton(MeasurementSheetController controller) {
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

  // Filter Dialog
  void _showFilterDialog(
    BuildContext context,
    MeasurementSheetController controller,
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

  // Shimmer Effect
  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 5,
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

  AppBar _buildAppbar(MeasurementSheetController controller) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Measurement Sheet',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.defaultBlack, // Change to your primary color
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              8,
            ), // Important for ripple effect
            onTap: () {
              Get.toNamed(AppRoutes.addPBOQ);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Optional icon
                  // Icon(Icons.add, size: ResponsiveHelper.getResponsiveFontSize(20)),
                  const SizedBox(width: 6),
                  Text(
                    'Add',
                    style: AppStyle.labelPrimaryPoppinsBlack.responsive
                        .copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(14),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // IconButton(
        //   onPressed: () {
        //     Get.toNamed(AppRoutes.addPBOQ);
        //   },
        //   icon: Row(
        //     children: [
        //       // Icon(Icons.add, size: ResponsiveHelper.getResponsiveFontSize(24)),
        //       Text(
        //         'Add',
        //         style: AppStyle.labelPrimaryPoppinsBlack.responsive.copyWith(
        //           fontSize: ResponsiveHelper.getResponsiveFontSize(14),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
