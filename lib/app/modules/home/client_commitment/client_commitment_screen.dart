import 'package:ashishinterbuild/app/modules/home/acc/acc_controller.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart' show AppRoutes;
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
                "Client Commitments ➔ Awaited Clearance From Client",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
            ),
            Padding(
              padding: ResponsiveHelper.padding(16),
              child: _buildSearchField(controller),
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
                                      _buildDetailRow(
                                        "Task Details",
                                        commitment.taskDetails,
                                      ),
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.screenHeight *
                                            0.002,
                                      ),
                                      if (controller.expandedIndex.value ==
                                          index) ...[
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
                                      Divider(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style:
                                                  AppButtonStyles.elevatedSmallBlack(),
                                              onPressed: () {
                                                controller.toggleExpanded(
                                                  index,
                                                );
                                              },
                                              child: Text(
                                                controller
                                                            .expandedIndex
                                                            .value ==
                                                        index
                                                    ? "Less"
                                                    : "Read",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsWhite,
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
                                                  AppButtonStyles.outlinedSmallBlack(),
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
                                                  AppButtonStyles.outlinedSmallBlack(),
                                              onPressed: () {
                                                // _showConfirmationDialog(context, sheet);
                                              },
                                              child: Text(
                                                "Delete",
                                                style: AppStyle
                                                    .labelPrimaryPoppinsBlack,
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
                      ),
              ),
            ),
          ],
        ),
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
          child: Text(label, style: AppStyle.reportCardTitle),
        ),
        const SizedBox(width: 8),
        Text(
          ': ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyle.reportCardSubTitle,
        ),
        Expanded(child: Text(value, style: AppStyle.reportCardSubTitle)),
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
        IconButton(
          onPressed: () {
            Get.toNamed(AppRoutes.addClientCommitment);
          },
          icon: const Icon(Icons.add),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: Colors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }
}
