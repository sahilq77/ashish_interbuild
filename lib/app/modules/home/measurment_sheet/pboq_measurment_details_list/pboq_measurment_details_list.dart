import 'package:ashishinterbuild/app/data/models/pboq/pboq_model.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_detail_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class PboqMeasurmentDetailsList extends StatelessWidget {
  const PboqMeasurmentDetailsList({super.key});

  @override
  Widget build(BuildContext context) {
    final PboqMeasurmentDetailController controller = Get.put(
      PboqMeasurmentDetailController(),
    );
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 16, left: 16, right: 16),
              child: Text(
                "Skyline Towers ➔ Measurement Sheet ➔ Measurement Detail",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                    padding: ResponsiveHelper.padding(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Text("Package Name", style: AppStyle.reportCardTitle),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.003),
                        Text(
                          "Prime Package",
                          style: AppStyle.reportCardSubTitle,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: ResponsiveHelper.padding(16),
                    padding: ResponsiveHelper.padding(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Text("PBOQ Name", style: AppStyle.reportCardTitle),
                        SizedBox(height: ResponsiveHelper.screenHeight * 0.003),
                        Text("PBOQ ", style: AppStyle.reportCardSubTitle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Search bar
            Padding(
              padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
              child: _buildSearchField(controller),
            ),

            // List view
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _shimmerList();
                }
                return controller.filteredPboqList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: ResponsiveHelper.padding(16),
                        itemCount: controller.filteredPboqList.length,
                        itemBuilder: (context, index) {
                          final PboqModel sheet =
                              controller.filteredPboqList[index];
                          return _buildCard(controller, sheet, index);
                        },
                      );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Search field with clear button
  Widget _buildSearchField(PboqMeasurmentDetailController controller) {
    return TextFormField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: 'Search by Package or CBOQ Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: controller.searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchPboq('');
                },
              )
            : const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: controller.searchPboq,
    );
  }

  // Card for a single PBOQ item
  Widget _buildCard(
    PboqMeasurmentDetailController controller,
    PboqModel sheet,
    int index,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.toggleExpanded(index),
        child: Card(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.screenHeight * 0.02),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              // border: Border(
              //   left: BorderSide(color: AppColors.primary, width: 5),
              // ),
            ),
            child: Padding(
              padding: ResponsiveHelper.padding(16),
              child: Column(
                children: [
                  _detailRow('PBOQ Name', sheet.pboq),
                  // _detailRow('PBOA', sheet.pboa),
                  // SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  // _detailRow('Zone', sheet.zone),
                  // SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  // _detailRow('Location', sheet.location),
                  // SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                  // _detailRow('MS Qty', sheet.msQty.toString()),
                  if (controller.expandedIndex.value == index) ...[
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('Package Name', sheet.packageName),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('CBOQ Name', sheet.cboqName),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('MS Qty', sheet.msQty.toString()),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    // _detailRow('PBOQ Name', sheet.pboq),
                    // SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('UOM', sheet.uom),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('PBOQ Qty', sheet.pboqQty),
                    _detailRow('PBOA', sheet.pboa),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('Zone', sheet.zone),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('Location', sheet.location),
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
                    _detailRow('Sub-Location', sheet.subLocation),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _detailRow('Remark', sheet.remark),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),

                    _detailRow(
                      'Updated On',
                      '${sheet.updatedOn.year}-${sheet.updatedOn.month.toString().padLeft(2, '0')}-${sheet.updatedOn.day.toString().padLeft(2, '0')}',
                    ),
                  ],
                  // SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
                  //   const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.start,
                          "Qty: ${sheet.msQty}",
                          style: AppStyle.labelPrimaryPoppinsBlack.responsive
                              .copyWith(fontSize: 13),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.screenWidth * 0.01),
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.start,
                          "Ms Qty: ${sheet.msQty}",
                          style: AppStyle.labelPrimaryPoppinsBlack.responsive
                              .copyWith(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: AppButtonStyles.outlinedExtraSmallPrimary(),
                          onPressed: () {
                            Get.toNamed(AppRoutes.deductionForm);
                          },
                          child: Text(
                            "Deduction: ${sheet.deduction}",
                            style: AppStyle.labelPrimaryPoppinsBlack.responsive
                                .copyWith(fontSize: 10),
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: ElevatedButton(
                      //     style: AppButtonStyles.elevatedSmallBlack(),
                      //     onPressed: () => controller.toggleExpanded(index),
                      //     child: Text(
                      //       controller.expandedIndex.value == index
                      //           ? 'Less'
                      //           : 'Read',
                      //       style: AppStyle.labelPrimaryPoppinsWhite,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(width: ResponsiveHelper.screenWidth * 0.05),

                      // Expanded(
                      //   child: OutlinedButton(
                      //     style: AppButtonStyles.outlinedSmallBlack(),
                      //     onPressed: () => Get.toNamed(AppRoutes.deductionForm),
                      //     child: Row(
                      //       children: [
                      //         Icon(Icons.add),
                      //         Text(
                      //           'Deduction',
                      //           style: AppStyle.labelPrimaryPoppinsBlack,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
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

  // Helper: Single label-value row
  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
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

  // Shimmer placeholder while loading
  Widget _shimmerList() {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 5,
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

  // Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No results found',
        style: GoogleFonts.poppins(
          color: AppColors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // AppBar
  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'PBOQ Details',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.toNamed(AppRoutes.addPBOQ);
          },
          icon: Row(
            children: [
              Icon(Icons.add, size: ResponsiveHelper.getResponsiveFontSize(24)),
              Text(
                'Add',
                style: AppStyle.labelPrimaryPoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
