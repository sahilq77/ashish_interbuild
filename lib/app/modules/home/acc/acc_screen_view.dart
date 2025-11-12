import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart' show AppRoutes;
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:shimmer/shimmer.dart';

class AccScreenView extends StatelessWidget {
  const AccScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final AccController controller = Get.put(AccController());
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveHelper.padding(16),
              child: Text(
                "Skyline Towers -> Awaited Clearance From Client",
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
                    : ListView.builder(
                        padding: ResponsiveHelper.padding(16),
                        itemCount: controller.accList.length,
                        itemBuilder: (context, index) {
                          final issue = controller.accList[index];
                          return GestureDetector(
                            onTap: () => controller.toggleExpanded(index),
                            child: Card(
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
                                child: Obx(
                                  () => Padding(
                                    padding: ResponsiveHelper.padding(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // _buildDetailRow(
                                        //   "Sr.No",
                                        //   issue.srNo.toString(),
                                        // ),
                                        // SizedBox(
                                        //   height:
                                        //       ResponsiveHelper.screenHeight *
                                        //       0.002,
                                        // ),
                                        _buildDetailRow(
                                          "ACC Category",
                                          issue.accCategory,
                                        ),
                                        SizedBox(
                                          height:
                                              ResponsiveHelper.screenHeight *
                                              0.002,
                                        ),
                                        _buildDetailRow("Role", issue.role),

                                        if (controller.expandedIndex.value ==
                                            index) ...[
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Package Name",
                                            issue.packageName,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Key Delay Events",
                                            issue.keyDelayEvents ? 'Yes' : 'No',
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Priority",
                                            issue.priority,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Issue Open Date",
                                            issue.issueOpenDate.toString(),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Overdue",
                                            issue.overdue.toString(),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow("Delay", issue.delay),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Issue Close Date",
                                            issue.issueCloseDate?.toString() ??
                                                "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Brief Detail",
                                            issue.briefDetail,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Affected Milestone",
                                            issue.affectedMilestone,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Attachment",
                                            issue.attachment,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Status Update",
                                            issue.statusUpdate,
                                          ),
                                        ],
                                        SizedBox(
                                          height:
                                              ResponsiveHelper.screenHeight *
                                              0.01,
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

  // ────── SORT BUTTON (UNCHANGED) ──────
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

  // ────── FILTER BUTTON (UNCHANGED) ──────
  Widget _buildFilterButton(BuildContext context, AccController controller) {
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

  // ────── FILTER DIALOG (UPDATED WITH 6 DROPDOWNS) ──────
  void _showFilterDialog(BuildContext context, AccController controller) {
    String? tempPackage = controller.selectedPackageFilter.value;
    String? tempCategory = controller.selectedCategoryFilter.value;
    String? tempPriority = controller.selectedPriorityFilter.value;
    String? tempMilestone = controller.selectedMilestoneFilter.value;
    String? tempRole = controller.selectedRoleFilter.value;
    String? tempKeyDelay = controller.selectedKeyDelayFilter.value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(20)),
          ),
          child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(ResponsiveHelper.spacing(20)),
                    ),
                  ),
                  child: Text(
                    'Filter ACC',
                    style: AppStyle.heading1PoppinsWhite.responsive,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // 1. Package Name
                _filterDropdown(
                  label: 'Package Name',
                  items: controller.packageNames,
                  selected: tempPackage,
                  onChanged: (v) => setState(() => tempPackage = v),
                  icon: Icons.business,
                ),

                // 2. Category
                _filterDropdown(
                  label: 'Category',
                  items: controller.categoryNames,
                  selected: tempCategory,
                  onChanged: (v) => setState(() => tempCategory = v),
                  icon: Icons.category,
                ),

                // 3. Priority
                _filterDropdown(
                  label: 'Priority',
                  items: controller.priorityNames,
                  selected: tempPriority,
                  onChanged: (v) => setState(() => tempPriority = v),
                  icon: Icons.flag,
                ),

                // 4. Affected Milestone
                _filterDropdown(
                  label: 'Affected Milestone',
                  items: controller.milestoneNames,
                  selected: tempMilestone,
                  onChanged: (v) => setState(() => tempMilestone = v),
                  icon: Icons.military_tech,
                ),

                // 5. Role
                _filterDropdown(
                  label: 'Role',
                  items: controller.roleNames,
                  selected: tempRole,
                  onChanged: (v) => setState(() => tempRole = v),
                  icon: Icons.person,
                ),

                // 6. Key Delay Events
                _filterDropdown(
                  label: 'Key Delay Events',
                  items: controller.keyDelayOptions,
                  selected: tempKeyDelay,
                  onChanged: (v) => setState(() => tempKeyDelay = v),
                  icon: Icons.event,
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
                            controller.selectedPackageFilter.value =
                                tempPackage;
                            controller.selectedCategoryFilter.value =
                                tempCategory;
                            controller.selectedPriorityFilter.value =
                                tempPriority;
                            controller.selectedMilestoneFilter.value =
                                tempMilestone;
                            controller.selectedRoleFilter.value = tempRole;
                            controller.selectedKeyDelayFilter.value =
                                tempKeyDelay;
                            controller.applyFilters();
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
      ),
    );
  }

  // ────── REUSABLE DROPDOWN (ADDED) ──────
  Widget _filterDropdown({
    required String label,
    required List<String> items,
    required String? selected,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 6),
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
        items: items,
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
        selectedItem: selected,
      ),
    );
  }

  // ────── SEARCH FIELD (UNCHANGED) ──────
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
      onChanged: controller.searchIssues,
    );
  }

  // ────── SHIMMER (UNCHANGED) ──────
  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: ResponsiveHelper.padding(16),
      itemCount: 5,
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
              ),
              child: Padding(
                padding: ResponsiveHelper.padding(16),
                child: Column(
                  children: [
                    _buildShimmerRow(),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.002),
                    _buildShimmerRow(),
                    SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
                    Divider(),
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

  // ────── DETAIL ROW (UNCHANGED) ──────
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

  // ────── APP BAR (UNCHANGED) ──────
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
}
