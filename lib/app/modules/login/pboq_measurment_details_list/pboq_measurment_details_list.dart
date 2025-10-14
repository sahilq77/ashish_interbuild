// pboq_measurment_details_list.dart
import 'package:ashishinterbuild/app/data/models/pboq/pboq_model.dart';
import 'package:ashishinterbuild/app/modules/login/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart'
    show AppButtonStyles;
import 'package:ashishinterbuild/app/widgets/app_style.dart' show AppStyle;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class PboqMeasurmentDetailsList extends StatelessWidget {
  const PboqMeasurmentDetailsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialise / retrieve the controller (GetX)
    final PboqMeasurmentDetailController controller = Get.put(
      PboqMeasurmentDetailController(),
    );

    // Init responsive helper (you already do this in your original code)
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Obx(() {
          // -------------------------------------------------
          // Loading state → show shimmer
          // -------------------------------------------------
          if (controller.isLoading.value) {
            return _shimmerList();
          }

          // -------------------------------------------------
          // Normal state → show real data
          // -------------------------------------------------
          return ListView.builder(
            padding: ResponsiveHelper.padding(16),
            itemCount: controller.pboqList.length,
            itemBuilder: (context, index) {
              final PboqModel sheet = controller.pboqList[index];
              return _buildCard(controller, sheet, index);
            },
          );
        }),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Card for a single PBOQ item
  // -------------------------------------------------------------------------
  Widget _buildCard(
    PboqMeasurmentDetailController controller,
    PboqModel sheet,
    int index,
  ) {
    return Obx(
      () => Card(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.screenHeight * 0.02),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 5),
            ),
          ),
          child: Padding(
            padding: ResponsiveHelper.padding(16),
            child: Column(
              children: [
                // Always visible rows
                _detailRow('Package Name', sheet.packageName),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                _detailRow('CBOQ Name', sheet.cboqName),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                _detailRow('MS Qty', sheet.msQty.toString()),

                // Expanded rows (appear only when the card is expanded)
                if (controller.expandedIndex.value == index) ...[
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('PBOQ Name', sheet.pboq),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Zone', sheet.zone),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('UOM', sheet.uom),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('PBOQ Qty', sheet.pboqQty),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Length', sheet.length.toString()),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Breadth', sheet.breadth.toString()),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Height', sheet.height.toString()),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Deduction', sheet.deduction.toString()),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Nos.', sheet.nos.toString()),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Source', sheet.source),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('CBOQ Code', sheet.cboqCode),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('PBOA', sheet.pboa),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Location', sheet.location),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Sub-Location', sheet.subLocation),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow('Remark', sheet.remark),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _detailRow(
                    'Updated On',
                    '${sheet.updatedOn.year}-${sheet.updatedOn.month.toString().padLeft(2, '0')}-${sheet.updatedOn.day.toString().padLeft(2, '0')}',
                  ),
                ],

                SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
                const Divider(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtonStyles.elevatedSmallPrimary(),
                        onPressed: () => controller.viewPboqDetails(sheet),
                        child: Text(
                          'View',
                          style: AppStyle.labelPrimaryPoppinsWhite,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.screenWidth * 0.05),
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtonStyles.elevatedSmallPrimary(),
                        onPressed: () => controller.toggleExpanded(index),
                        child: Text(
                          controller.expandedIndex.value == index
                              ? 'Collapse'
                              : 'Read',
                          style: AppStyle.labelPrimaryPoppinsWhite,
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
  }

  // -------------------------------------------------------------------------
  // Helper: a single label-value row
  // -------------------------------------------------------------------------
  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: AppStyle.reportCardTitle),
        ),
        const SizedBox(width: 8),
        Text(': ', style: AppStyle.reportCardSubTitle),
        Expanded(
          child: Text(
            value,
            style: AppStyle.reportCardSubTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Shimmer placeholder while loading
  // -------------------------------------------------------------------------
  Widget _shimmerList() {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 5, // arbitrary number of shimmer cards
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.screenHeight * 0.02),
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
                  _shimmerRow(),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _shimmerRow(),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  _shimmerRow(),
                  SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
                  const Divider(),
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
      ),
    );
  }

  Widget _shimmerRow() {
    return Row(
      children: [
        Container(width: 130, height: 16, color: Colors.grey.shade300),
        const SizedBox(width: 8),
        Text(': ', style: AppStyle.reportCardSubTitle),
        Expanded(child: Container(height: 16, color: Colors.grey.shade300)),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // AppBar
  // -------------------------------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.white),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'PBOQ Details',
        style: AppStyle.heading1PoppinsWhite.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Navigate to add-screen (replace with your route)
            Get.toNamed('/addPBOQ');
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
