import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_list_response.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
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
import 'package:dropdown_search/dropdown_search.dart';

class PboqMeasurmentDetailsList extends StatefulWidget {
  const PboqMeasurmentDetailsList({super.key});

  @override
  State<PboqMeasurmentDetailsList> createState() =>
      _PboqMeasurmentDetailsListState();
}

class _PboqMeasurmentDetailsListState extends State<PboqMeasurmentDetailsList> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PboqMeasurmentDetailController>();
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(controller),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Skyline Towers to Measurement Sheet",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
            ),

            // Search + Filter + Sort
            Padding(
              padding: ResponsiveHelper.padding(16),
              child: Row(
                children: [
                  Expanded(child: _searchField(controller)),

                  const SizedBox(width: 8),
                  _sortButton(controller),
                ],
              ),
            ),

            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _shimmer();
                }
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
                if (controller.filteredPboqList.isEmpty) {
                  // NEW: Check if search is active
                  if (controller.searchController.text.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No search result found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search keywords',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text('No data found'));
                  }
                }

                return ListView.builder(
                  padding: ResponsiveHelper.padding(16),
                  itemCount:
                      controller.filteredPboqList.length +
                      (controller.hasMoreData.value ||
                              controller.isLoadingMore.value
                          ? 1
                          : 1),
                  itemBuilder: (ctx, i) {
                    // Handle last item: loading or "No more data"
                    if (i >= controller.filteredPboqList.length) {
                      // Trigger load more only if needed
                      if (controller.hasMoreData.value &&
                          !controller.isLoadingMore.value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.loadMore(context);
                        });
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

                    // Normal item rendering (unchanged)
                    final item = controller.filteredPboqList[i];
                    print(item);

                    return GestureDetector(
                      onTap: () => controller.toggleExpanded(i),
                      child: Obx(() {
                        final isExpanded = controller.expandedIndex.value == i;
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
                                  ...controller.getFrontDisplayColumns().map((
                                    col,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: _dynamicRow(
                                        col,
                                        controller.getFieldValue(item, col),
                                      ),
                                    );
                                  }).toList(),

                                  // ---- Expanded Content (All Columns) ----
                                  if (isExpanded) ...[
                                    // const SizedBox(height: 4),

                                    // Remaining front-display columns
                                    ...controller
                                        .getFrontDisplayColumns()
                                        .skip(1)
                                        .map(
                                          (col) => Padding(
                                            padding:
                                                ResponsiveHelper.paddingSymmetric(
                                                  vertical: 2,
                                                ),
                                            child: _dynamicRow(
                                              col,
                                              controller.getFieldValue(
                                                item,
                                                col,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),

                                    // All other columns NOT in frontDisplayColumns
                                    ...controller
                                        .getAllColumns()
                                        .where(
                                          (col) => !controller
                                              .getFrontDisplayColumns()
                                              .contains(col),
                                        )
                                        .map(
                                          (col) => Padding(
                                            padding:
                                                ResponsiveHelper.paddingSymmetric(
                                                  vertical: 2,
                                                ),
                                            child: _dynamicRow(
                                              col,
                                              controller.getFieldValue(
                                                item,
                                                col,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],

                                  const SizedBox(height: 8),

                                  // ---- Footer row (Qty / Amt / MS Qty button) ----

                                  // ---- Footer row (dynamic button columns) ----
                                  Row(
                                    children: [
                                      // 1. Fixed “Qty / Amt” (you can keep or remove them)
                                      ...controller
                                          .getFrontSecondaryDisplayColumns()
                                          .map((col) {
                                            return Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 6,
                                                ),
                                                child: Text(
                                                  "$col: ${controller.getFieldValue(item, col)}",
                                                  style: AppStyle
                                                      .labelPrimaryPoppinsBlack
                                                      .responsive
                                                      .copyWith(fontSize: 13),
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                      // Expanded(
                                      //   child: Text(
                                      //     "PBOQ Qty: ${item.pboqQty}",
                                      //     style: AppStyle
                                      //         .labelPrimaryPoppinsBlack
                                      //         .responsive
                                      //         .copyWith(fontSize: 13),
                                      //   ),
                                      // ),
                                      // const SizedBox(width: 4),
                                      // Expanded(
                                      //   child: Text(
                                      //     "Amt: ${item.msQty}", // or any other amount you need
                                      //     style: AppStyle
                                      //         .labelPrimaryPoppinsBlack
                                      //         .responsive
                                      //         .copyWith(fontSize: 13),
                                      //   ),
                                      // ),
                                      const SizedBox(width: 8),

                                      // 2. **Dynamic ElevatedButtons** for every button_display_column
                                      ...controller.getButtonDisplayColumns().map((
                                        col,
                                      ) {
                                        final String label =
                                            "$col: ${controller.getFieldValue(item, col)}";

                                        return Expanded(
                                          child: OutlinedButton(
                                            style:
                                                AppButtonStyles.outlinedExtraSmallPrimary(),
                                            onPressed: () {
                                              // Example navigation – adapt to your real route
                                              Get.toNamed(
                                                AppRoutes.deductionForm,
                                                // arguments: {
                                                //   'pboq_id': item.pboqId,
                                                //   'column': col,
                                                // },
                                              );
                                            },
                                            child: Text(
                                              label,
                                              style: AppStyle
                                                  .labelPrimaryPoppinsBlack
                                                  .responsive
                                                  .copyWith(fontSize: 10),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.edit,
                                          color: AppColors.defaultBlack,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                            context,
                                          );
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Delete',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this record ?',
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
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Delete',
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

  // -------------------------------------------------------------------------
  Widget _dynamicRow(String label, String value) {
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
        const SizedBox(width: 8),
        Text(': ', style: AppStyle.reportCardSubTitle),
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

  // -------------------------------------------------------------------------
  Widget _searchField(PboqMeasurmentDetailController c) {
    return TextFormField(
      controller: c.searchController,
      decoration: InputDecoration(
        hintText: 'Search....',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.search, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: c.searchSurveys,
    );
  }

  // -------------------------------------------------------------------------
  Widget _sortButton(PboqMeasurmentDetailController c) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(
            c.isAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
            color: AppColors.primary,
          ),
          onPressed: c.toggleSorting,
          padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _shimmer() {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.screenHeight * 0.02),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  AppBar _buildAppBar(PboqMeasurmentDetailController c) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'PBOQ Measurment Sheet List',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.defaultBlack, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Get.toNamed(AppRoutes.addPBOQ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
