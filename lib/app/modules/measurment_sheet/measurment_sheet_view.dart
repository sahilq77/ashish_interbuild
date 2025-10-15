import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/modules/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class MeasurmentSheetView extends StatelessWidget {
  const MeasurmentSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final MeasurementSheetController controller = Get.find();
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          children: [
            // Add search field
            Padding(
              padding: ResponsiveHelper.padding(16),
              child: _buildSearchField(controller),
            ),
            // Expanded to make ListView take remaining space
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
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: 5,
                                  ),
                                ),
                              ),
                              child: Obx(
                                () => Padding(
                                  padding: ResponsiveHelper.padding(16),
                                  child: Column(
                                    children: [
                                      _buildDetailRow(
                                        "Package Name",
                                        sheet.packageName,
                                      ),
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.screenHeight *
                                            0.002,
                                      ),
                                      _buildDetailRow(
                                        "CBOQ Name",
                                        sheet.cboqName,
                                      ),
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.screenHeight *
                                            0.002,
                                      ),
                                      _buildDetailRow("MS Qty", sheet.msQty),
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
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.screenHeight *
                                            0.01,
                                      ),
                                      Divider(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style:
                                                  AppButtonStyles.elevatedSmallPrimary(),
                                              onPressed: () {
                                                controller.viewMeasurementSheet(
                                                  sheet,
                                                );
                                                Get.toNamed(AppRoutes.pboqList);
                                              },
                                              child: Text(
                                                "View",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsWhite,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width:
                                                ResponsiveHelper.screenWidth *
                                                0.05,
                                          ),
                                          Expanded(
                                            child: ElevatedButton(
                                              style:
                                                  AppButtonStyles.elevatedSmallPrimary(),
                                              onPressed: () {
                                                controller.toggleExpanded(
                                                  index,
                                                );
                                              },
                                              child: Text(
                                                controller
                                                            .expandedIndex
                                                            .value ==
                                                        index
                                                    ? "Collapse"
                                                    : "Read",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsWhite,
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildSearchField(MeasurementSheetController controller) {
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
          child: Text(label, style: AppStyle.reportCardTitle),
        ),
        const SizedBox(width: 8),
        Text(
          ': ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyle.reportCardSubTitle,
        ),
        Expanded(child: Text(value, style: AppStyle.reportCardSubTitle)),
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
      iconTheme: const IconThemeData(color: AppColors.white),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Measurement Sheet',
        style: AppStyle.heading1PoppinsWhite.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.toNamed(AppRoutes.addPBOQ);
            // Add functionality to add a new measurement sheet
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
