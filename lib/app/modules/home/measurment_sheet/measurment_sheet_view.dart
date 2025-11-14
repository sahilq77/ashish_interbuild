import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_list_response.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MeasurmentSheetView extends StatelessWidget {
  const MeasurmentSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeasurementSheetController>();
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
                  _filterButton(context, controller),
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

                if (controller.filteredPboqList.isEmpty) {
                  return const Center(child: Text('No data found'));
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
                        controller.loadMore(context);
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
                                  // ---- Primary row (always visible) ----
                                  _dynamicRow(
                                    controller.frontDisplayColumns.isNotEmpty
                                        ? controller.frontDisplayColumns
                                              .firstWhere(
                                                (c) => c == "CBOQ No",
                                                orElse: () => controller
                                                    .frontDisplayColumns[0],
                                              )
                                        : "–",
                                    _valueForColumn(
                                      item,
                                      controller.frontDisplayColumns.isNotEmpty
                                          ? controller.frontDisplayColumns[0]
                                          : "",
                                    ),
                                  ),

                                  // ---- Expanded Content (All Columns) ----
                                  if (isExpanded) ...[
                                    const SizedBox(height: 4),

                                    // Remaining front-display columns
                                    ...controller.frontDisplayColumns
                                        .skip(1)
                                        .map(
                                          (col) => Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: _dynamicRow(
                                              col,
                                              _valueForColumn(item, col),
                                            ),
                                          ),
                                        )
                                        .toList(),

                                    // All other columns NOT in frontDisplayColumns
                                    ...controller.appColumnDetails.value.columns
                                        .where(
                                          (col) => !controller
                                              .frontDisplayColumns
                                              .value
                                              .contains(col),
                                        )
                                        .map(
                                          (col) => Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: _dynamicRow(
                                              col,
                                              _valueForColumn(item, col),
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
                                      Expanded(
                                        child: Text(
                                          "Qty: ${item.pboqQty}",
                                          style: AppStyle
                                              .labelPrimaryPoppinsBlack
                                              .responsive
                                              .copyWith(fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "Amt: ${item.msQty}", // or any other amount you need
                                          style: AppStyle
                                              .labelPrimaryPoppinsBlack
                                              .responsive
                                              .copyWith(fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // 2. **Dynamic ElevatedButtons** for every button_display_column
                                      ...controller.buttonDisplayColumns.map((
                                        col,
                                      ) {
                                        final String label =
                                            "$col: ${_valueForColumn(item, col)}";

                                        return Expanded(
                                          child: OutlinedButton(
                                            style:
                                                AppButtonStyles.outlinedExtraSmallPrimary(),
                                            onPressed: () {
                                              // Example navigation – adapt to your real route
                                              Get.toNamed(
                                                AppRoutes.pboqList,
                                                arguments: {
                                                  'pboq_id': item.pboqId,
                                                  'column': col,
                                                },
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

  // -------------------------------------------------------------------------
  // Helper: get value for any column (dynamic)
  // -------------------------------------------------------------------------
  String _valueForColumn(AllData item, String column) {
    switch (column) {
      case 'System ID':
        return item.systemId;
      case 'PBOQ Name':
        return item.pboqName;
      case 'CBOQ No':
        return item.cboqNo;
      case 'Package Name':
        return item.packageName;
      case 'UOM':
        return item.uom;
      case 'Zones':
        return item.zones;
      case 'PBOQ Qty':
        return item.pboqQty;
      case 'MS Qty':
        return item.msQty.toString();
      default:
        return '';
    }
  }

  // -------------------------------------------------------------------------
  // Dynamic label-value row
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
  // Search field
  // -------------------------------------------------------------------------
  Widget _searchField(MeasurementSheetController c) {
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
  // Filter button + dialog
  // -------------------------------------------------------------------------
  Widget _filterButton(BuildContext ctx, MeasurementSheetController c) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_list, color: AppColors.primary),
        onPressed: () => _showFilterDialog(ctx, c),
        padding: EdgeInsets.all(ResponsiveHelper.spacing(8)),
        constraints: const BoxConstraints(),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, MeasurementSheetController c) {
    String? temp = c.selectedPackageFilter.value;

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
              // Header
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.paddingSymmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Text(
                  'Filter Measurement Sheets',
                  style: AppStyle.heading1PoppinsWhite.responsive,
                  textAlign: TextAlign.center,
                ),
              ),

              // Dropdown
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
                  items: c.getPackageNames(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Package',
                      border: const OutlineInputBorder(),
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
                  onChanged: (v) => setState(() => temp = v),
                  selectedItem: temp,
                ),
              ),

              // Buttons
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
                          c.clearFilters();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear',
                          style: AppStyle.labelPrimaryPoppinsBlack.responsive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          c.selectedPackageFilter.value = temp;
                          c.applyFilters();
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

  // -------------------------------------------------------------------------
  // Sort button
  // -------------------------------------------------------------------------
  Widget _sortButton(MeasurementSheetController c) {
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
  // Shimmer
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
  // AppBar
  // -------------------------------------------------------------------------
  AppBar _buildAppBar(MeasurementSheetController c) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'PBOQ List',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 16),
        //   decoration: BoxDecoration(
        //     border: Border.all(color: AppColors.defaultBlack, width: 0.5),
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: InkWell(
        //     borderRadius: BorderRadius.circular(8),
        //     onTap: () => Get.toNamed(AppRoutes.addPBOQ),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           const SizedBox(width: 6),
        //           Text(
        //             'Add',
        //             style: AppStyle.labelPrimaryPoppinsBlack.responsive
        //                 .copyWith(
        //                   fontSize: ResponsiveHelper.getResponsiveFontSize(14),
        //                 ),
        //           ),
        //         ],
        //       ),
        //     ),
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
