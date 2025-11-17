import 'package:ashishinterbuild/app/data/models/measurement_sheet/get_pboq_list_response.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone_locations/zone_locations_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/add_pboq/add_pboq_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_deduction/deduction_form/measurment_sheet_deduction_list/measurment_sheet_deduction_list_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MeasurmentSheetDeductionList extends StatefulWidget {
  const MeasurmentSheetDeductionList({super.key});

  @override
  State<MeasurmentSheetDeductionList> createState() =>
      _MeasurmentSheetDeductionListState();
}

class _MeasurmentSheetDeductionListState
    extends State<MeasurmentSheetDeductionList> {
  final controller = Get.find<MeasurmentSheetDeductionListController>();
  final zoneController = Get.find<ZoneController>();
  final zoneLocationController = Get.find<ZoneLocationController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    zoneController.fetchZones(context: context);
    zoneLocationController.fetchZoneLocations(context: context);
  }

  @override
  Widget build(BuildContext context) {
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
                "Skyline Towers to Deduction",
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
                  _buildFilterButton(context),
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
                                              // final addMScontrolller = Get.put(
                                              //   AddPboqFormController(),
                                              // );
                                              // // Example navigation – adapt to your real route
                                              // addMScontrolller.uom.value =
                                              //     item.uom;
                                              Get.toNamed(
                                                AppRoutes.pboqList,
                                                arguments: {
                                                  'pboq_id': int.parse(
                                                    item.pboqId,
                                                  ),
                                                  'column': col,
                                                  'uom': item.uom,
                                                  'length': int.parse(
                                                    controller.getLength(item),
                                                  ),
                                                  'breadth': int.parse(
                                                    controller.getBreadth(item),
                                                  ),
                                                  'height': int.parse(
                                                    controller.getHeight(item),
                                                  ),
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
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: SizedBox(width: double.infinity),
                                  //     ),
                                  //     Expanded(
                                  //       child: SizedBox(width: double.infinity),
                                  //     ),
                                  //     Expanded(
                                  //       child: GestureDetector(
                                  //         onTap: () {
                                  //           Get.toNamed(
                                  //             AppRoutes
                                  //                 .measurmentSheetDeductionList,
                                  //             arguments: {
                                  //               'project_id':
                                  //                   controller.projectId,
                                  //               'package_id':
                                  //                   controller.packageId,
                                  //             },
                                  //           );
                                  //         },
                                  //         child:
                                  //             AppButtonStyles.outlinedExtraSmallBlackContainer(
                                  //               child: Text(
                                  //                 "View Deduction",
                                  //                 style: AppStyle
                                  //                     .labelPrimaryPoppinsBlack
                                  //                     .responsive
                                  //                     .copyWith(fontSize: 10),
                                  //               ),
                                  //             ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
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
  Widget _searchField(MeasurmentSheetDeductionListController c) {
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
    final controller = Get.find<MeasurmentSheetDeductionListController>();
    final zoneController = Get.find<ZoneController>();
    final zoneLocationController = Get.find<ZoneLocationController>();

    String? tempZone = controller.selectedZone.value.isEmpty
        ? null
        : controller.selectedZone.value;
    String? tempZoneLocation = controller.selectedZoneLocation.value.isEmpty
        ? null
        : controller.selectedZoneLocation.value;

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
                  'Filters',
                  style: AppStyle.heading1PoppinsWhite.responsive,
                  textAlign: TextAlign.center,
                ),
              ),
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
                    ],
                  ),
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
                          controller.selectedZone.value = tempZone ?? '';
                          controller.selectedZoneLocation.value =
                              tempZoneLocation ?? '';
                          controller.fetchPboq(reset: true, context: context);
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
    final List<String> fullList = ['', ...items];

    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(vertical: 6),
      child: DropdownSearch<String>(
        popupProps: const PopupProps.menu(
          showSearchBox: true,
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
        itemAsString: (s) => s.isEmpty ? 'All' : s,
      ),
    );
  }

  // -------------------------------------------------------------------------
  Widget _sortButton(MeasurmentSheetDeductionListController c) {
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
  AppBar _buildAppBar(MeasurmentSheetDeductionListController c) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Deduction',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
