import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart' show AppRoutes;
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:ashishinterbuild/app/widgets/app_button_style.dart';
import 'package:shimmer/shimmer.dart';

class ClientCommitmentScreen extends StatelessWidget {
  const ClientCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientCommitmentController controller = Get.put(
      ClientCommitmentController(),
    );
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
                "CC Dashboard ➔ Client Commitments",
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
                        itemCount: controller.commitmentList.length,
                        itemBuilder: (context, index) {
                          final commitment = controller.commitmentList[index];
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
                                        _buildDetailRow(
                                          "Sr. No.",
                                          commitment.srNo.toString(),
                                        ),
                                        SizedBox(
                                          height:
                                              ResponsiveHelper.screenHeight *
                                              0.002,
                                        ),
                                        _buildDetailRow(
                                          "Task Assigned To",
                                          commitment.taskAssignedTo,
                                        ),
                                        SizedBox(
                                          height:
                                              ResponsiveHelper.screenHeight *
                                              0.002,
                                        ),
                                        _buildDetailRow("HOD", commitment.hod),

                                        SizedBox(
                                          height:
                                              ResponsiveHelper.screenHeight *
                                              0.002,
                                        ),
                                        if (controller.expandedIndex.value ==
                                            index) ...[
                                          _buildDetailRow(
                                            "Task Details",
                                            commitment.taskDetails,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Affected Milestone",
                                            commitment.affectedMilestone,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Priority",
                                            commitment.priority ?? "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Milestone Target Date",
                                            commitment.milestoneTargetDate
                                                .toString(),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Initial Target Date",
                                            commitment.initialTargetDate
                                                .toString(),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "CC Category",
                                            commitment.ccCategory,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Overdue Days",
                                            commitment.overdueDays.toString(),
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Delay",
                                            commitment.delay ?? "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Revised Completion Date",
                                            commitment.revisedCompletionDate
                                                    ?.toString() ??
                                                "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Close Date",
                                            commitment.closeDate?.toString() ??
                                                "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Status Update",
                                            commitment.statusUpdate,
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Attachment",
                                            commitment.attachment ?? "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.002,
                                          ),
                                          _buildDetailRow(
                                            "Remark",
                                            commitment.remark ?? "-",
                                          ),
                                          SizedBox(
                                            height:
                                                ResponsiveHelper.screenHeight *
                                                0.01,
                                          ),
                                        ],
                                        // Divider(),
                                        Row(
                                          children: [
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
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallBlack(),
                                                onPressed: () {
                                                  Get.toNamed(
                                                    AppRoutes
                                                        .updateClientCommitment,
                                                  );
                                                },
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
                                            Expanded(
                                              child: OutlinedButton(
                                                style:
                                                    AppButtonStyles.outlinedExtraSmallBlack(),
                                                onPressed: () {
                                                  Get.toNamed(
                                                    AppRoutes
                                                        .editClientCommitment,
                                                  );
                                                },
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
                                                onPressed: () {
                                                  // _showConfirmationDialog(
                                                  //   context,
                                                  //   sheet,
                                                  // );
                                                },
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

  Widget _buildFilterButton(
    BuildContext context,
    ClientCommitmentController controller,
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

  Widget _buildSortButton(ClientCommitmentController controller) {
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

  // ────── FILTER DIALOG (REFACTORED WITH ICONS) ──────
  void _showFilterDialog(
    BuildContext context,
    ClientCommitmentController controller,
  ) {
    // temporary values – applied only on “Apply”
    String? tempRole = controller.selectedRole.value;
    String? tempHod = controller.selectedHod.value;
    String? tempCategory = controller.selectedCategory.value;
    String? tempMilestone = controller.selectedMilestone.value;
    String? tempPriority = controller.selectedPriority.value;
    String? tempIssueOpen = controller.selectedIssueOpen.value;

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
                        label: 'Role',
                        items: controller.roleList,
                        selected: tempRole,
                        onChanged: (v) => setState(() => tempRole = v),
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'HOD',
                        items: controller.hodList,
                        selected: tempHod,
                        onChanged: (v) => setState(() => tempHod = v),
                        icon: Icons.supervisor_account,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'Category',
                        items: controller.categoryList,
                        selected: tempCategory,
                        onChanged: (v) => setState(() => tempCategory = v),
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'Affected Milestone',
                        items: controller.milestoneList,
                        selected: tempMilestone,
                        onChanged: (v) => setState(() => tempMilestone = v),
                        icon: Icons.military_tech,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'Priority',
                        items: controller.priorityList,
                        selected: tempPriority,
                        onChanged: (v) => setState(() => tempPriority = v),
                        icon: Icons.flag,
                      ),
                      const SizedBox(height: 12),
                      _filterDropdownWithIcon(
                        label: 'Issue Open',
                        items: const ['Yes', 'No'],
                        selected: tempIssueOpen,
                        onChanged: (v) => setState(() => tempIssueOpen = v),
                        icon: Icons.check_circle,
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
                          controller.selectedRole.value = tempRole ?? '';
                          controller.selectedHod.value = tempHod ?? '';
                          controller.selectedCategory.value =
                              tempCategory ?? '';
                          controller.selectedMilestone.value =
                              tempMilestone ?? '';
                          controller.selectedPriority.value =
                              tempPriority ?? '';
                          controller.selectedIssueOpen.value =
                              tempIssueOpen ?? '';

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
    );
  }

  // Helper widget used inside the dialog
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

  TextFormField _buildSearchField(ClientCommitmentController controller) {
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
      onChanged: controller.searchCommitments,
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

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Client Commitments',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.defaultBlack, // Change to your primary color
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              8,
            ), // Important for ripple effect
            onTap: () {
              Get.toNamed(AppRoutes.addClientCommitment);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Optional icon
                  // Icon(Icons.add, size: ResponsiveHelper.getResponsiveFontSize(20)),
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
        // IconButton(
        //   onPressed: () {
        //     Get.toNamed(AppRoutes.addClientCommitment);
        //   },
        //   icon: const Icon(Icons.add),
        // ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: Colors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
