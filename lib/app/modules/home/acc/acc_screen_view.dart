import 'dart:io';

import 'package:ashishinterbuild/app/modules/global_controller/zone/zone_controller.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart' show AppRoutes;
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';

class AccScreenView extends StatefulWidget {
  const AccScreenView({super.key});

  @override
  State<AccScreenView> createState() => _AccScreenViewState();
}

class _AccScreenViewState extends State<AccScreenView> {
  @override
  Widget build(BuildContext context) {
    final AccController controller = Get.put(AccController());
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(top: 16, left: 16, right: 16),
              child: Text(
                "Home ➔ Acc List",
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
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? _buildShimmerEffect(context)
                    : controller.errorMessage.value.isNotEmpty
                    ? Center(
                        child: Text(
                          controller.errorMessage.value,
                          style: AppStyle.bodyBoldPoppinsBlack.responsive,
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

                          final sheet =
                              controller.filteredMeasurementSheets[index];
                          return GestureDetector(
                            onTap: () => controller.toggleExpanded(index),
                            child: Obx(() {
                              final isExpanded =
                                  controller.expandedIndex.value == index;
                              return Card(
                                margin: EdgeInsets.only(
                                  bottom: ResponsiveHelper.screenHeight * 0.02,
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
                                                            .workFrontUpdateDetailList,
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
                                                          "packageName": controller
                                                              .getFieldValue(
                                                                sheet,
                                                                "Package Name",
                                                              ),
                                                          "pboqName": controller
                                                              .getFieldValue(
                                                                sheet,
                                                                "PBOQ",
                                                              ),
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallBlack(),
                                                onPressed: () => Get.toNamed(
                                                  AppRoutes.updateAccForm,
                                                ),
                                                child: Text(
                                                  "Update",
                                                  style: AppStyle
                                                      .labelPrimaryPoppinsBlack,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                                  ResponsiveHelper.screenWidth *
                                                  0.05,
                                            ),
                                            // Row(
                                            //   children: [
                                            //     IconButton(
                                            //       onPressed: () {},
                                            //       icon: Icon(
                                            //         Icons.edit,
                                            //         color:
                                            //             AppColors.defaultBlack,
                                            //       ),
                                            //     ),
                                            //     IconButton(
                                            //       onPressed: () {},
                                            //       icon: Icon(Icons.delete),
                                            //     ),
                                            //   ],
                                            // ),
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallBlack(),
                                                onPressed: () => Get.toNamed(
                                                  AppRoutes.editAccForm,
                                                ),
                                                child: Icon(Icons.edit),
                                              ),
                                            ),
                                            SizedBox(
                                              width:
                                                  ResponsiveHelper.screenWidth *
                                                  0.05,
                                            ),
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallPrimary(),
                                                onPressed: () {},
                                                child: Icon(Icons.delete),
                                              ),
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Format Date
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  TextFormField _buildSearchField(AccController controller) {
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
                    children: List.generate(1, (index) {
                      final fileName =
                          value +
                          DateTime.now()
                              .toString()
                              .split('/')
                              .last
                              .split('?')
                              .first;
                      return GestureDetector(
                        onTap: () async {
                          await _downloadImage(value, fileName);
                          print("Download ${value}");
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

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'ACC',
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
            onTap: () => Get.toNamed(AppRoutes.addAccForm),
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
        child: Divider(color: Colors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, AccController controller) {
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
    final AccController controller = Get.put(AccController());
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
                          controller.fetchWFUList(
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

  Widget _buildSortButton(AccController controller) {
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
