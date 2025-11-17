import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_controller.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class DailyProgressReportDashboard extends StatelessWidget {
  const DailyProgressReportDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyProgressReportDashboardController controller = Get.find();
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
                  "Skyline Towers ➔ DPR Dashboard",
                  style: AppStyle.bodySmallPoppinsPrimary,
                ),
                SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
                Obx(
                  () => controller.isLoading.value
                      ? GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                          mainAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                          childAspectRatio: 1.3,
                          children: List.generate(
                            6,
                            (index) => _buildShimmerItem(),
                          ),
                        )
                      : GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                          mainAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                          childAspectRatio: 1.3,
                          children: [
                            _buildGridItem(
                              'Monthly Target',
                              controller.formatCurrency(
                                controller.monthlyTarget.value,
                              ),
                              controller.formatPercentage(
                                controller.monthlyPercent.value,
                              ),
                              Colors.indigo,
                              true,
                              showPercent: false,
                            ),
                            _buildGridItem(
                              'Monthly Achieve',
                              controller.formatCurrency(
                                controller.monthlyAchieve.value,
                              ),
                              controller.formatPercentage(
                                controller.monthlyPercent.value,
                              ),
                              Colors.teal,
                              true,
                              showPercent: true,
                            ),
                            _buildGridItem(
                              'Weekly Target',
                              controller.formatCurrency(
                                controller.weeklyTarget.value,
                              ),
                              controller.formatPercentage(
                                controller.weeklyPercent.value,
                              ),
                              Colors.deepOrange,
                              true,
                              showPercent: false,
                            ),
                            _buildGridItem(
                              'Weekly Achieve',
                              controller.formatCurrency(
                                controller.weeklyAchieve.value,
                              ),
                              controller.formatPercentage(
                                controller.weeklyPercent.value,
                              ),
                              Colors.deepPurple,
                              true,
                              showPercent: true,
                            ),
                            _buildGridItem(
                              'Today\'s Target',
                              controller.formatCurrency(
                                controller.dailyTarget.value,
                              ),
                              controller.formatPercentage(
                                controller.dailyPercent.value,
                              ),
                              Colors.amber,
                              true,
                              showPercent: false,
                            ),
                            _buildGridItem(
                              'Today\'s Achieve',
                              controller.formatCurrency(
                                controller.dailyAchieve.value,
                              ),
                              controller.formatPercentage(
                                controller.dailyPercent.value,
                              ),
                              Colors.green,
                              true,
                              showPercent: true,
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
    bool isColor, {
    bool showPercent =
        true, // New parameter with default true (for backward compatibility if needed)
  }) {
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
                  // Only show percent box if showPercent is true
                  if (showPercent)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: ResponsiveHelper.padding(5),
                          padding: ResponsiveHelper.padding(5),
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
                    )
                  else
                    const SizedBox(height: 30), // Optional: maintain spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title placeholder
              Container(
                height: 16,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              // Count placeholder
              Container(height: 24, width: 80, color: Colors.white),
              const Spacer(),
              // Percent box placeholder (only for achieve cards)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(width: 40, height: 16, color: Colors.white),
                ),
              ),
            ],
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
        'DPR Dashboard',
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
