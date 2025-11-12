import 'package:ashishinterbuild/app/modules/home/work_front_update/work_front_update_list_view/work_front_update_list_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class WorkFrontUpdateListView extends StatelessWidget {
  const WorkFrontUpdateListView({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkFrontUpdateListController controller = Get.find();
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
            // Breadcrumb
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Text(
                "Skyline Towers > WFU Dashboard > Work Front Update",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
            ),

            // Search + Filter + Sort
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

            // List
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
                            onTap: () => controller.toggleExpanded(index),
                            child: Card(
                              margin: EdgeInsets.only(
                                bottom: ResponsiveHelper.spacing(16),
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
                                child: Obx(
                                  () => Padding(
                                    padding: ResponsiveHelper.padding(16),
                                    child: Column(
                                      children: [
                                        // ----- Header (always visible) -----
                                        _buildDetailRow(
                                          "PBOQ Name",
                                          sheet.pboq,
                                        ),

                                        // ----- Expandable details -----
                                        if (controller.expandedIndex.value ==
                                            index) ...[
                                          _buildDetailRow("PBOA", sheet.pboa),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow(
                                            "PBOA Qty",
                                            "${sheet.pboaQty}",
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow(
                                            "PBOA Rate",
                                            "${sheet.pboaRate}",
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow(
                                            "System ID",
                                            "${sheet.systemId}",
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow(
                                            "CBOQ Code",
                                            sheet.cboqCode,
                                          ),
                                          _buildDetailRow("Doer", sheet.doer),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow("UOM", sheet.uom),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow("Fix", sheet.fix),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow("Trade", sheet.trade),
                                          SizedBox(
                                            height: ResponsiveHelper.spacing(4),
                                          ),
                                          _buildDetailRow("Zone", sheet.zone),
                                        ],

                                        SizedBox(
                                          height: ResponsiveHelper.spacing(8),
                                        ),

                                        // ----- Bottom row -----
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Qty: ${sheet.msQty}",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsBlack
                                                    .responsive
                                                    .copyWith(fontSize: 13),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "Amt: ${sheet.amount}",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsBlack
                                                    .responsive
                                                    .copyWith(fontSize: 13),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallPrimary(),
                                                onPressed: () {
                                                  // Get.toNamed(AppRoutes.updateWorkFront);
                                                },
                                                child: Text(
                                                  "Update",
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

  // -----------------------------------------------------------------
  // UI Helpers
  // -----------------------------------------------------------------
  TextFormField _buildSearchField(WorkFrontUpdateListController controller) {
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
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(16)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 5),
                ),
              ),
              child: Padding(
                padding: ResponsiveHelper.padding(16),
                child: Column(
                  children: [
                    _buildShimmerRow(),
                    const SizedBox(height: 4),
                    _buildShimmerRow(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            color: Colors.grey.shade300,
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
        const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
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
        const SizedBox(width: 8),
        const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
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

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Work Front Update',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: Divider(color: AppColors.grey, height: 0),
      ),
    );
  }

  // ---------- Filter Button ----------
  Widget _buildFilterButton(
    BuildContext context,
    WorkFrontUpdateListController controller,
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

  // ---------- Filter Dialog (NOW WITH PACKAGE + ZONE) ----------
  void _showFilterDialog(
    BuildContext context,
    WorkFrontUpdateListController controller,
  ) {
    String? tempSelectedPackage = controller.selectedPackageFilter.value;
    String? tempSelectedZone = controller.selectedZoneFilter.value;

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
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Text(
                  'Filter Work Front',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Package Dropdown
              Padding(
                padding: ResponsiveHelper.padding(20),
                child: DropdownSearch<String>(
                  popupProps: const PopupProps.menu(showSearchBox: true),
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
                  onChanged: (v) => setState(() => tempSelectedPackage = v),
                  selectedItem: tempSelectedPackage,
                ),
              ),

              // Zone Dropdown
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: DropdownSearch<String>(
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  items: controller.getZoneNames(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Zone',
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
                        Icons.location_on,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  onChanged: (v) => setState(() => tempSelectedZone = v),
                  selectedItem: tempSelectedZone,
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
                          controller.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppColors.defaultBlack),
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
                          controller.selectedZoneFilter.value =
                              tempSelectedZone;
                          controller.applyFilters();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
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

  // ---------- Sort Button ----------
  Widget _buildSortButton(WorkFrontUpdateListController controller) {
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
