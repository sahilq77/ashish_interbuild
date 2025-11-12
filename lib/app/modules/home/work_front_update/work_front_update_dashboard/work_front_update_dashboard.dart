import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard_controller.dart';
import 'package:ashishinterbuild/app/modules/home/work_front_update/work_front_update_dashboard/work_front_update_dashboard_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkFrontUpdateDashboard extends StatelessWidget {
  const WorkFrontUpdateDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkFrontUpdateDashboardController controller = Get.find();
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: ResponsiveHelper.padding(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Skyline Towers ➔ WFU Dashboard",
                  style: AppStyle.bodySmallPoppinsPrimary,
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
                Obx(
                  () => GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                    mainAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                    childAspectRatio: 1.3,
                    children: [
                      _buildGridItem(
                        'Total Amount',
                        controller.formatCurrency(
                          controller.monthlyTarget.value,
                        ),
                        controller.formatPercentage(
                          controller.monthlyPercent.value,
                        ),
                        Colors.indigo,
                        true,
                      ),
                      _buildGridItem(
                        'Total Rec Amount',
                        controller.formatCurrency(
                          controller.monthlyAchieve.value,
                        ),
                        controller.formatPercentage(
                          controller.monthlyPercent.value,
                        ),
                        Colors.teal,
                        true,
                      ),
                      _buildGridItem(
                        'Total Rec %',
                        controller.formatPercentage(
                          controller.weeklyPercent.value,
                        ),
                        controller.formatPercentage(
                          controller.weeklyPercent.value,
                        ),
                        Colors.deepOrange,
                        true,
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

  Widget _buildGridItem(
    String title,
    String count,
    String percent,
    Color gradientColor,
    bool isColor,
  ) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.dailyProgressReport);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Get.toNamed(AppRoutes.dailyProgressReport);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppStyle.dashTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isColor ? gradientColor : AppColors.defaultBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Container(
                  //       margin: ResponsiveHelper.padding(5),
                  //       padding: ResponsiveHelper.padding(5),
                  //       alignment: Alignment.bottomRight,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(5),
                  //         border: Border.all(
                  //           color: AppColors.grey.withOpacity(0.5),
                  //         ),
                  //         color: AppColors.white,
                  //       ),
                  //       child: Center(
                  //         child: Text(percent, style: AppStyle.dashPercent),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.defaultBlack),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'WFU Dashboard',
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
}
