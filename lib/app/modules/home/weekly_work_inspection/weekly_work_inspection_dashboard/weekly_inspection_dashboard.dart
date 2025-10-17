import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_work_inspection_dashboard/weekly_inspection_dashboard_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyInspectionDashboard extends StatelessWidget {
  const WeeklyInspectionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final WeeklyInspectionDashboardController controller = Get.find();
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: Padding(
        padding: ResponsiveHelper.padding(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
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
                    'Monthly Target',
                    controller.formatCurrency(controller.monthlyTarget.value),
                    controller.formatPercentage(
                      controller.monthlyPercent.value,
                    ),
                    AppColors.grey,
                    false,
                  ),
                  _buildGridItem(
                    'Monthly Achieve',
                    controller.formatCurrency(controller.monthlyAchieve.value),
                    controller.formatPercentage(
                      controller.monthlyPercent.value,
                    ),
                    AppColors.grey,
                    false,
                  ),
                  _buildGridItem(
                    'Weekly Target',
                    controller.formatCurrency(controller.weeklyTarget.value),
                    controller.formatPercentage(controller.weeklyPercent.value),
                    AppColors.blue,
                    true,
                  ),
                  _buildGridItem(
                    'Weekly Achieve',
                    controller.formatCurrency(controller.weeklyAchieve.value),
                    controller.formatPercentage(controller.weeklyPercent.value),
                    AppColors.greenColor,
                    true,
                  ),
                  _buildGridItem(
                    'Today\'s Target',
                    controller.formatCurrency(controller.dailyTarget.value),
                    controller.formatPercentage(controller.dailyPercent.value),
                    AppColors.accentOrange,
                    true,
                  ),
                  _buildGridItem(
                    'Today\'s Achieve',
                    controller.formatCurrency(controller.dailyAchieve.value),
                    controller.formatPercentage(controller.dailyPercent.value),
                    AppColors.greenColor,
                    true,
                  ),
                ],
              ),
            ),
          ],
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
        Get.toNamed(AppRoutes.weeklyInspection);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: gradientColor.withOpacity(0.5)),
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
              Get.toNamed(AppRoutes.weeklyInspection);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: ResponsiveHelper.padding(5),
                        padding: ResponsiveHelper.padding(5),
                        alignment: Alignment.bottomRight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.5),
                          ),
                          color: AppColors.white,
                        ),
                        child: Center(
                          child: Text(percent, style: AppStyle.dashPercent),
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
  }

  AppBar _buildAppbar() {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.white),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Weekly Inspection Dashboard',
        style: AppStyle.heading1PoppinsWhite.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
