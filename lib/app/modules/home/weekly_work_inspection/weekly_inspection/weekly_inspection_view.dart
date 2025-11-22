import 'package:ashishinterbuild/app/modules/global_controller/weekly_period/weekly_period_controller.dart';
import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_controller.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class WeeklyInspectionView extends StatefulWidget {
  const WeeklyInspectionView({super.key});

  @override
  State<WeeklyInspectionView> createState() => _WeeklyInspectionViewState();
}

class _WeeklyInspectionViewState extends State<WeeklyInspectionView> {
  final WeeklyPeriodController weeklypController = Get.find();
  @override
  Widget build(BuildContext context) {
    final WeeklyInspectionController controller = Get.find();
    ResponsiveHelper.init(context);
    return WillPopScope(
      onWillPop: () async {
        controller.projectId.value = 0;
        controller.packageId.value = 0;
        return true;
      },
      child: Scaffold(
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
                  "Skyline Towers → WIR Dashboard → WIR",
                  style: AppStyle.bodySmallPoppinsPrimary,
                ),
              ),
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
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                child: Row(
                  children: [
                    Obx(
                      () => SizedBox(
                        width: ResponsiveHelper.screenWidth * 0.300,
                        child: _buildDropdownField(
                          label: 'Year',
                          value: controller.selectedYear.value,
                          items: controller.yearList,
                          onChanged: (v) {
                            controller.selectedYear.value = v ?? '';
                            weeklypController.selectedPeriodVal.value = "";
                            weeklypController.periodLabels.clear();
                            weeklypController.fetchPeriods(
                              context: context,
                              forceFetch: true,
                              year: int.parse(controller.selectedYear.value),
                            );
                          },
                          hint: 'Year',
                          enabled: true,
                          errorText: "",
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(5)),
                    Expanded(
                      child: Obx(
                        () => _buildDropdownField(
                          label: 'Week',
                          value: weeklypController.selectedPeriodVal.value,
                          items: weeklypController.periodLabels,
                          onChanged: (v) {
                            if (v != null) {
                              final selectedPeriod = weeklypController
                                  .periodsList
                                  .firstWhere(
                                    (p) => p.label == v,
                                    orElse: () =>
                                        weeklypController.periodsList.first,
                                  );
                              controller.filterInspectionFromDate.value =
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedPeriod.weekFromDate);
                              controller.filterInspectionToDate.value =
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedPeriod.weekToDate);
                              controller.fetchDprList(
                                reset: true,
                                context: context,
                              );
                            }
                          },
                          hint: 'Week',
                          enabled: true,
                          errorText: "",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
                child: Text(
                  "Note: By Default Current Ongoing Week's Inspection Targets are showed",
                  style: AppStyle.bodySmallPoppinsPrimary,
                ),
              ),

              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? _buildShimmerEffect(context)
                      : controller.errorMessage.value.isNotEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Text(
                                controller.errorMessage.value,
                                style: AppStyle.bodyBoldPoppinsBlack.responsive,
                              ),
                            ),
                          ),
                        )
                      : controller.filteredMeasurementSheets.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(child: Text('No data found')),
                          ),
                        )
                      : ListView.builder(
                          padding: ResponsiveHelper.padding(16),
                          itemCount:
                              controller.filteredMeasurementSheets.length +
                              (controller.hasMoreData.value ||
                                      controller.isLoadingMore.value
                                  ? 1
                                  : 0),
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
                                          ),
                                        ),
                                ),
                              );
                            }

                            final sheet =
                                controller.filteredMeasurementSheets[index];
                            return GestureDetector(
                              onTap: () => controller.toggleExpanded(index),
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
                                                  .isNotEmpty)
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

                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.01,
                                          ),
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
                                                        Get.toNamed(
                                                          AppRoutes
                                                              .updateWeeklyInspection,
                                                          arguments: {
                                                            "selected_source":
                                                                controller
                                                                    .getFieldValue(
                                                                      sheet,
                                                                      "Source",
                                                                    ),
                                                            "selected_system_id":
                                                                controller
                                                                    .getFieldValue(
                                                                      sheet,
                                                                      "System ID",
                                                                    ),
                                                            "uom": controller
                                                                .getFieldValue(
                                                                  sheet,
                                                                  "UOM",
                                                                ),

                                                            // "fromDate"
                                                            // "toDate": 
                                                          },
                                                        );
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
      ),
    );
  }

  // Helper: Format Date
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  TextFormField _buildSearchField(WeeklyInspectionController controller) {
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
            style: AppStyle.reportCardTitle.responsive.copyWith(fontSize: 13),
          ),
        ),
        SizedBox(width: 8),
        Text(': ', style: AppStyle.reportCardSubTitle),
        Expanded(
          child: Text(
            value,
            style: AppStyle.reportCardSubTitle.responsive.copyWith(
              fontSize: 13,
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
        'Weekly Inspsection List',
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

  Widget _buildFilterButton(
    BuildContext context,
    WeeklyInspectionController controller,
  ) {
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
    final WeeklyInspectionController controller = Get.put(
      WeeklyInspectionController(),
    );
    final zoneController = Get.find<ZoneController>();

    String? tempZone = controller.selectedZone.value.isEmpty
        ? null
        : controller.selectedZone.value;

    // Initialize temp dates
    controller.tempStartDate = controller.selectedStartDate.value.isNotEmpty
        ? DateTime.tryParse(controller.selectedStartDate.value)
        : null;
    controller.tempEndDate = controller.selectedEndDate.value.isNotEmpty
        ? DateTime.tryParse(controller.selectedEndDate.value)
        : null;

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
              Flexible(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.paddingSymmetric(
                    horizontal: 16,
                    vertical: 16,
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
                      const SizedBox(height: 16),
                      // DATE RANGE PICKER
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
                              "Date Range",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                final picked = await showDateRangePicker(
                                  context: ctx,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  initialDateRange:
                                      controller.tempStartDate != null &&
                                          controller.tempEndDate != null
                                      ? DateTimeRange(
                                          start: controller.tempStartDate!,
                                          end: controller.tempEndDate!,
                                        )
                                      : null,
                                  builder: (context, child) => Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  final daysDifference = picked.end
                                      .difference(picked.start)
                                      .inDays;
                                  if (daysDifference > 7) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Date range cannot exceed 7 days',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    controller.tempStartDate = picked.start;
                                    controller.tempEndDate = picked.end;
                                    setState(() {});
                                  }
                                }
                              },
                              child: Container(
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
                                    const Icon(
                                      Icons.date_range,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        controller.tempStartDate == null
                                            ? "Select Date Range"
                                            : "${_formatDate(controller.tempStartDate!)} → ${_formatDate(controller.tempEndDate!)}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              controller.tempStartDate == null
                                              ? Colors.grey[600]
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (controller.tempStartDate != null)
                                      InkWell(
                                        onTap: () {
                                          controller.tempStartDate = null;
                                          controller.tempEndDate = null;
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                          if (controller.tempStartDate != null &&
                              controller.tempEndDate != null) {
                            controller.selectedStartDate.value =
                                "${controller.tempStartDate!.year}-${controller.tempStartDate!.month.toString().padLeft(2, '0')}-${controller.tempStartDate!.day.toString().padLeft(2, '0')}";
                            controller.selectedEndDate.value =
                                "${controller.tempEndDate!.year}-${controller.tempEndDate!.month.toString().padLeft(2, '0')}-${controller.tempEndDate!.day.toString().padLeft(2, '0')}";
                          } else {
                            controller.selectedStartDate.value = '';
                            controller.selectedEndDate.value = '';
                          }
                          controller.fetchDprList(
                            context: context,
                            reset: true,
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
    final List<String> fullList = ['', ...items];
    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(vertical: 6),
      child: DropdownSearch<String>(
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          showSelectedItems: true,
        ),
        items: fullList,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(8),
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

  Widget _buildSortButton(WeeklyInspectionController controller) {
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

  // Dropdown Field
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    required String hint,
    bool enabled = true,
    String? errorText, // Add this
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.reportCardRowCount.responsive),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          selectedItem: value.isNotEmpty ? value : null,
          items: items,
          onChanged: onChanged,
          enabled: enabled,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: !enabled,
              fillColor: !enabled ? Colors.grey[200] : null,
              errorText: errorText, // Show error
            ),
          ),
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
        ),
      ],
    );
  }
}
