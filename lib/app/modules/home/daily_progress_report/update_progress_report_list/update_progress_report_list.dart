import 'dart:developer';

import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/pboq/pboq_name_controller.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/update_progress_report_list/update_progress_report_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'dart:developer';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class UpdateProgressReportList extends StatefulWidget {
  const UpdateProgressReportList({super.key});

  @override
  State<UpdateProgressReportList> createState() =>
      _UpdateProgressReportListState();
}

class _UpdateProgressReportListState extends State<UpdateProgressReportList> {
  final UpdateProgressReportController controller = Get.find();

  final zoneController = Get.put(ZoneController());
  final zoneLocationController = Get.put(ZoneLocationController());
  final pboqController = Get.put(PboqNameController());
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      controller.sourceName.value = args["selected_source"] ?? "";
      controller.systemId.value = args["selected_system_id"] ?? "";
      controller.uom.value = args["uom"] ?? "";
      controller.packageName.value = args["packageName"] ?? "";
      controller.pboqName.value = args["pboqName"] ?? "";
    }

    // Set default values if still 0

    log(
      "DPR Detail → Source=${controller.sourceName.value} System Id=${controller.systemId.value}",
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        controller.fetchDprList(reset: true, context: Get.context!);
        zoneController.fetchZones(context: Get.context!);
        zoneLocationController.fetchZoneLocations(context: Get.context!);
        pboqController.fetchPboqs(
          context: Get.context!,
          projectId: controller.dprController.projectId.value,
          packageId: controller.dprController.packageId.value,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return WillPopScope(
      onWillPop: () async {
        controller.selectedIndices.clear();
        controller.rowImages.clear();
        controller.isMultiSelectMode.value = false;
        return true;
      },
      child: Scaffold(
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
                  "Skyline Towers ➔ DPR Dashboard ➔ DPR",
                  style: AppStyle.bodySmallPoppinsPrimary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          Text("Package Name", style: AppStyle.reportCardTitle),
                          SizedBox(
                            height: ResponsiveHelper.screenHeight * 0.003,
                          ),
                          Obx(
                            () => Text(
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              controller.packageName.value,
                              style: AppStyle.reportCardSubTitle,
                            ),
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
                          SizedBox(
                            height: ResponsiveHelper.screenHeight * 0.003,
                          ),
                          Obx(
                            () => Text(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              controller.pboqName.value,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.reportCardSubTitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Add search field
              Padding(
                padding: ResponsiveHelper.padding(16),
                child: Row(
                  children: [
                    Expanded(child: _buildSearchField(controller)),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    _buildFilterButton(context),
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
                          itemCount:
                              controller.filteredMeasurementSheets.length +
                              (controller.hasMoreData.value ||
                                      controller.isLoadingMore.value
                                  ? 1
                                  : 1),
                          itemBuilder: (context, index) {
                            if (index >=
                                controller.filteredMeasurementSheets.length) {
                              if (controller.hasMoreData.value &&
                                  !controller.isLoadingMore.value) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  controller.loadMore(context);
                                });
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Center(
                                  child: controller.hasMoreData.value
                                      ? const CircularProgressIndicator()
                                      : Text(
                                          'No more data',
                                          style: TextStyle(
                                            color: AppColors.grey,
                                            fontSize:
                                                ResponsiveHelper.getResponsiveFontSize(
                                                  14,
                                                ),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                ),
                              );
                            }

                            final sheet =
                                controller.filteredMeasurementSheets[index];
                            return GestureDetector(
                              onTap: () {
                                if (controller.isMultiSelectMode.value &&
                                    controller.getFieldValue(
                                          sheet,
                                          "execution_status",
                                        ) ==
                                        "0") {
                                  controller.toggleItemSelection(index);
                                } else if (!controller
                                    .isMultiSelectMode
                                    .value) {
                                  controller.toggleExpanded(index);
                                }
                              },
                              onLongPress: () {
                                if (controller.getFieldValue(
                                      sheet,
                                      "execution_status",
                                    ) ==
                                    "0") {
                                  controller.startMultiSelect(index);
                                }
                              },
                              child: Obx(() {
                                final isExpanded =
                                    controller.expandedIndex.value == index;
                                return Card(
                                  margin: EdgeInsets.only(
                                    bottom:
                                        ResponsiveHelper.screenHeight * 0.02,
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
                                    ),
                                    child: Padding(
                                      padding: ResponsiveHelper.padding(16),
                                      child: Column(
                                        children: [
                                          if (controller
                                              .getFrontDisplayColumns()
                                              .isNotEmpty)
                                            ...controller
                                                .getFrontDisplayColumns()
                                                .take(1)
                                                .map((col) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 6,
                                                        ),
                                                    child: _buildDetailRow(
                                                      col,
                                                      controller.getFieldValue(
                                                        sheet,
                                                        col,
                                                      ),
                                                    ),
                                                  );
                                                })
                                                .toList(),

                                          if (isExpanded &&
                                              controller
                                                  .appColumnDetails
                                                  .value
                                                  .columns
                                                  .isNotEmpty) ...[
                                            ...controller
                                                .appColumnDetails
                                                .value
                                                .columns
                                                .where(
                                                  (col) => !controller
                                                      .getFrontDisplayColumns()
                                                      .contains(col),
                                                )
                                                .map(
                                                  (col) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 6,
                                                        ),
                                                    child: _buildDetailRow(
                                                      col,
                                                      controller.getFieldValue(
                                                        sheet,
                                                        col,
                                                      ),
                                                    ),
                                                  ),
                                                )
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
                                              if (controller
                                                  .getFrontSecondaryDisplayColumns()
                                                  .isNotEmpty)
                                                ...controller
                                                    .getFrontSecondaryDisplayColumns()
                                                    .map((col) {
                                                      return Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                bottom: 6,
                                                              ),
                                                          child: Text(
                                                            "$col: ${controller.getFieldValue(sheet, col)}",
                                                            style: AppStyle
                                                                .labelPrimaryPoppinsBlack
                                                                .responsive
                                                                .copyWith(
                                                                  fontSize: 13,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    })
                                                    .toList(),
                                              const SizedBox(width: 8),
                                              if (controller
                                                  .getButtonDisplayColumns()
                                                  .isNotEmpty)
                                                ...controller.getButtonDisplayColumns().map((
                                                  col,
                                                ) {
                                                  return Expanded(
                                                    child: OutlinedButton(
                                                      style:
                                                          AppButtonStyles.outlinedExtraSmallPrimary(),
                                                      onPressed: () {
                                                        // Get.toNamed(
                                                        //   AppRoutes
                                                        //       .updateDailyReportList,
                                                        // );
                                                      },
                                                      child: Text(
                                                        "$col: ${controller.getFieldValue(sheet, col)}",
                                                        style: AppStyle
                                                            .labelPrimaryPoppinsBlack
                                                            .responsive
                                                            .copyWith(
                                                              fontSize: 10,
                                                            ),
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
                                          Obx(
                                            () => Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (controller
                                                            .isMultiSelectMode
                                                            .value &&
                                                        controller.getFieldValue(
                                                              sheet,
                                                              "execution_status",
                                                            ) ==
                                                            "0")
                                                      Transform.scale(
                                                        scale: 1.2,
                                                        child: Checkbox(
                                                          value: controller
                                                              .selectedIndices
                                                              .contains(index),
                                                          onChanged: (val) {
                                                            controller
                                                                .toggleItemSelection(
                                                                  index,
                                                                );
                                                          },
                                                          activeColor:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    const Spacer(),
                                                    if (controller.getFieldValue(
                                                          sheet,
                                                          "execution_status",
                                                        ) ==
                                                        "0")
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (controller
                                                                  .rowImages
                                                                  .containsKey(
                                                                    index,
                                                                  ) &&
                                                              controller
                                                                      .rowImages[index] !=
                                                                  null &&
                                                              controller
                                                                  .rowImages[index]!
                                                                  .isNotEmpty)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .primary
                                                                    .withOpacity(
                                                                      0.1,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                '${controller.rowImages[index]!.length} images',
                                                                style: TextStyle(
                                                                  color: AppColors
                                                                      .primary,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          IconButton(
                                                            onPressed: () =>
                                                                controller
                                                                    .pickImageForRow(
                                                                      index,
                                                                    ),
                                                            icon: Icon(
                                                              Icons.add_a_photo,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      _updatedBadge(),
                                                  ],
                                                ),
                                                if (controller.rowImages
                                                        .containsKey(index) &&
                                                    controller
                                                            .rowImages[index] !=
                                                        null &&
                                                    controller
                                                        .rowImages[index]!
                                                        .isNotEmpty)
                                                  Container(
                                                    height: 80,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: controller
                                                          .rowImages[index]!
                                                          .length,
                                                      itemBuilder: (context, imageIndex) {
                                                        final image = controller
                                                            .rowImages[index]![imageIndex];
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                right: 8,
                                                              ),
                                                          child: Stack(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                child: Image.file(
                                                                  File(
                                                                    image.path,
                                                                  ),
                                                                  width: 60,
                                                                  height: 60,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 2,
                                                                right: 2,
                                                                child: ElevatedButton(
                                                                  onPressed: () =>
                                                                      controller.removeImageFromRow(
                                                                        index,
                                                                        imageIndex,
                                                                      ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red, // button background
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white, // ripple color
                                                                    shape:
                                                                        const CircleBorder(), // makes it round
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          2,
                                                                        ), // small padding
                                                                    minimumSize:
                                                                        const Size(
                                                                          20,
                                                                          20,
                                                                        ), // compact size
                                                                    tapTargetSize:
                                                                        MaterialTapTargetSize
                                                                            .shrinkWrap, // reduces extra tap area
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons.close,
                                                                    size: 12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
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
                              }),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomButton(controller),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    UpdateProgressReportController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Reduced border radius
          ),
          title: Text(
            'Confirm Update',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            ),
          ),
          content: Text(
            'Are you sure you want to update?',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.getResponsiveFontSize(14),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: AppButtonStyles.outlinedSmallBlack(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: AppStyle.labelPrimaryPoppinsBlack,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.elevatedSmallBlack(),
                    onPressed: () {
                      controller.batchUpdateSelectedDPRs();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Confirm',
                      style: AppStyle.labelPrimaryPoppinsWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _updatedBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(1.0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.greenColor.withOpacity(0.9),
            AppColors.greenColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            "Updated",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(UpdateProgressReportController controller) {
    return Obx(
      () => Container(
        padding: ResponsiveHelper.paddingSymmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (!controller.isMultiSelectMode.value) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.toggleMultiSelectMode,
                      style: AppButtonStyles.outlinedLargeBlack(),
                      child: Text(
                        'Select Items',
                        style: AppStyle.buttonTextPoppinsBlack.responsive
                            .copyWith(fontSize: 15),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.toggleMultiSelectMode,
                      style: AppButtonStyles.outlinedMediumBlack(),
                      child: Text(
                        'Cancel',
                        style: AppStyle.buttonTextPoppinsBlack.responsive
                            .copyWith(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.selectedIndices.length == 0
                          ? null
                          : () => _showConfirmationDialog(context, controller),
                      style: AppButtonStyles.elevatedMediumBlack(),
                      child: controller.isLoadingu.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Update (${controller.selectedIndices.length})',
                              style: AppStyle.buttonTextPoppinsWhite.responsive
                                  .copyWith(fontSize: 15),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildSearchField(UpdateProgressReportController controller) {
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
    List<String> imageLink = [];
    imageLink = _extractImageLinks(value);

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
          child:
              value.contains(("jpg")) ||
                  value.contains(("jpeg")) ||
                  value.contains(("png"))
              ? Padding(
                  padding: EdgeInsets.only(left: ResponsiveHelper.spacing(5)),
                  child: Wrap(
                    spacing: ResponsiveHelper.spacing(
                      5,
                    ), // horizontal space between icons
                    runSpacing: ResponsiveHelper.spacing(
                      5,
                    ), // vertical space between lines
                    alignment: WrapAlignment
                        .start, // same as your centerStart behavior
                    children: List.generate(imageLink.length, (index) {
                      final fileName =
                          imageLink[index] +
                          DateTime.now()
                              .toString()
                              .split('/')
                              .last
                              .split('?')
                              .first;
                      return GestureDetector(
                        onTap: () async {
                          await _downloadImage(imageLink[index], fileName);
                          print("Download ${imageLink[index]}");
                        },
                        child: Chip(
                          label: Icon(Icons.download, color: AppColors.primary),
                        ),
                      );
                    }),
                  ),
                )
              : Text(
                  value,
                  style: AppStyle.reportCardSubTitle.responsive.copyWith(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                  ),
                ),
        ),
      ],
    );
  }

  Future<bool> _requestImageDownloadPermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    Permission permission;
    if (androidInfo.version.sdkInt >= 33) {
      // Android 13+ → Use Photos permission for images
      permission = Permission.photos;
    } else {
      // Older Android → Use storage
      permission = Permission.storage;
    }

    var status = await permission.status;

    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isPermanentlyDenied) {
      // Fluttertoast.showToast(
      //   msg: "Please allow photos/storage access in Settings → Apps → Your App",
      //   toastLength: Toast.LENGTH_LONG,
      // );
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<void> _downloadImage(String url, String originalFileName) async {
    try {
      // Request permission
      if (!await _requestImageDownloadPermission()) {
        AppSnackbarStyles.showError(
          title: "Permission Denied",
          message: "Cannot download image without storage permission",
        );
        return;
      }

      // Get directory (preferably Downloads)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.existsSync()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        AppSnackbarStyles.showError(
          title: "Error",
          message: "Cannot access storage",
        );
        return;
      }

      // Create a clean and unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final dateFormatted = DateFormat(
        'yyyyMMdd_HHmmss',
      ).format(DateTime.now());

      // Extract extension safely
      String extension = '.jpg'; // default
      final uri = Uri.tryParse(url);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final lastSegment = uri.pathSegments.last;
        final dotIndex = lastSegment.lastIndexOf('.');
        if (dotIndex != -1 && dotIndex < lastSegment.length - 1) {
          extension = lastSegment.substring(dotIndex); // includes the dot
          if (![
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
          ].contains(extension.toLowerCase())) {
            extension = '.jpg'; // fallback
          }
        }
      }

      // Final filename: IMG_20251122_153045_123.jpg
      final fileName = 'IMG_${dateFormatted}_$timestamp$extension';
      final savePath = "${directory.path}/$fileName";

      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            Fluttertoast.showToast(
              msg: "Downloading: $progress%",
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
      );

      final file = File(savePath);
      if (await file.exists() && await file.length() > 0) {
        AppSnackbarStyles.showSuccess(
          title: "Success",
          message: "Image saved as $fileName",
        );
      } else {
        throw Exception("File is empty or not created");
      }
    } catch (e) {
      debugPrint("Download error: $e");
      AppSnackbarStyles.showError(
        title: "Failed",
        message: "Could not download image",
      );
    }
  }

  List<String> _extractImageLinks(String text) {
    if (text.isEmpty) return [];

    final RegExp imageRegex = RegExp(
      r'https?://[^\s]+?\.(jpg|jpeg|png|gif|webp)(\?[^\s]*)?',
      caseSensitive: false,
    );

    final matches = imageRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();

    if (matches.isEmpty) {
      // Fallback: split by comma, space, or semicolon
      return text.split(RegExp(r'[\s,;]+')).where((s) {
        final trimmed = s.trim();
        return trimmed.contains(
          RegExp(r'\.(jpg|jpeg|png|gif|webp)', caseSensitive: false),
        );
      }).toList();
    }

    return matches;
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

  AppBar _buildAppbar(UpdateProgressReportController controller) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Obx(
        () => Text(
          controller.isMultiSelectMode.value
              ? 'Select Items (${controller.selectedIndices.length})'
              : 'Daily Progress Report',
          style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        Obx(() {
          if (controller.dprCount.value.isEmpty) {
            return const Center(child: Text(""));
          }

          final count = controller.dprCount.value.first;
          // return Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   decoration: BoxDecoration(
          //     border: Border.all(color: AppColors.defaultBlack, width: 0.5),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: InkWell(
          //     borderRadius: BorderRadius.circular(8),
          //     onTap: () {
          //       Get.toNamed(
          //         AppRoutes.addPBOQ,
          //         arguments: {
          //           "project_id": int.parse(count.projectId),
          //           "package_id": int.parse(count.packageId),
          //           "pboq_id": int.parse(count.pboqId),
          //           "uom": controller.uom.value,
          //         },
          //       );
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 10,
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           const SizedBox(width: 6),
          //           Text(
          //             'Add',
          //             style: AppStyle.labelPrimaryPoppinsBlack.responsive
          //                 .copyWith(
          //                   fontSize: ResponsiveHelper.getResponsiveFontSize(
          //                     14,
          //                   ),
          //                 ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // );

          return count.totalMs == 0 || 0 > count.totalMs
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.defaultBlack,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.addPBOQ,
                        arguments: {
                          "project_id": int.parse(count.projectId),
                          "package_id": int.parse(count.packageId),
                          "pboq_id": int.parse(count.pboqId),
                          "uom": controller.uom.value,
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            'Add',
                            style: AppStyle.labelPrimaryPoppinsBlack.responsive
                                .copyWith(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        14,
                                      ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink();
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: AppColors.primary),
        onPressed: () => _showFilterDialog(context),
        padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
        constraints: const BoxConstraints(),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final controller = Get.find<UpdateProgressReportController>();
    final zoneController = Get.find<ZoneController>();
    final zoneLocationController = Get.find<ZoneLocationController>();

    String? tempZone = controller.selectedZone.value.isEmpty
        ? null
        : controller.selectedZone.value;
    String? tempZoneLocation = controller.selectedZoneLocation.value.isEmpty
        ? null
        : controller.selectedZoneLocation.value;
    DateTime? tempDate = controller.selectedDate.value;
    // temporary values – applied only on “Apply”

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.paddingSymmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.defaultBlack,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ResponsiveHelper.spacing(20)),
                  ),
                ),
                child: Text(
                  'Filters',
                  style: AppStyle.heading1PoppinsWhite.responsive,
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Scrollable filter list ───────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.paddingSymmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      _filterDropdownWithIcon(
                        label: 'Zone',
                        items: zoneController.zoneNames,
                        selected: tempZone,
                        onChanged: (v) => setState(() => tempZone = v),
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'Zone Location',
                        items: zoneLocationController.zoneLocationNames,
                        selected: tempZoneLocation,
                        onChanged: (v) => setState(() => tempZoneLocation = v),
                        icon: Icons.place,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'PBOQ',
                        items: pboqController.pboqNames,
                        selected: controller.selectedPboq.value.isEmpty
                            ? null
                            : controller.selectedPboq.value,
                        onChanged: (v) =>
                            controller.selectedPboq.value = v ?? '',
                        icon: Icons.list_alt,
                      ),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Date",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: tempDate ?? DateTime.now(),
                                  firstDate: DateTime(2015),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => tempDate = date);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tempDate != null
                                          ? DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(tempDate!)
                                          : 'Select Date',
                                      style: TextStyle(
                                        color: tempDate != null
                                            ? AppColors.defaultBlack
                                            : AppColors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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

              // ── Buttons ───────────────────────────────────────
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: AppButtonStyles.outlinedMediumBlack(),
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
                        style: AppButtonStyles.elevatedMediumBlack(),

                        onPressed: () {
                          controller.selectedZone.value = tempZone ?? '';
                          controller.selectedZoneLocation.value =
                              tempZoneLocation ?? '';
                          controller.selectedDate.value = tempDate;
                          controller.fetchDprList(
                            reset: true,
                            context: context,
                          );
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

  Widget _filterDropdownWithIcon({
    required String label,
    required List<String> items,
    required String? selected,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    // prepend an empty entry so “All” can be selected
    final List<String> fullList = ['', ...items];

    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(vertical: 6),
      child: DropdownSearch<String>(
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
            ),
          ),
        ),
        items: fullList,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(8)),
            ),
            prefixIcon: Icon(icon, color: AppColors.primary),
          ),
        ),
        onChanged: onChanged,
        selectedItem: selected ?? '',
        // Show “All” for the empty entry
        itemAsString: (s) => s.isEmpty ? 'All' : s,
      ),
    );
  }

  // Sort Button
  Widget _buildSortButton(UpdateProgressReportController controller) {
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
