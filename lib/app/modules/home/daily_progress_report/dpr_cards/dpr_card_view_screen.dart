import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class DprCardViewScreen extends StatefulWidget {
  const DprCardViewScreen({super.key});

  @override
  State<DprCardViewScreen> createState() => _DprCardViewScreenState();
}

class _DprCardViewScreenState extends State<DprCardViewScreen> {
  int? projectId;
  int? packageId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      projectId = args["project_id"] ?? 0;
      packageId = args["package_id"] ?? 0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppbar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: ResponsiveHelper.padding(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Skyline Towers ➔ DPR",
                style: AppStyle.bodySmallPoppinsPrimary,
              ),
              SizedBox(height: ResponsiveHelper.screenHeight * 0.03),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                mainAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                childAspectRatio: 1.3,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.dailyProgressReport,
                        arguments: {
                          "project_id": projectId,
                          "package_id": packageId,
                        },
                      );
                    },
                    child: _buildGlassCard("DPR"),
                  ),
                  _buildGlassCard("DPR Detail"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set solid white background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.defaultBlack, // Keep red border
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // Optional subtle inner glow (can be removed if not needed)
            // Positioned.fill(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       gradient: RadialGradient(
            //         colors: [
            //           Colors.white.withOpacity(0.2),
            //           Colors.transparent,
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(13),
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(
                          0.95,
                        ), // Consider changing to a darker color
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AppBar _buildAppbar() {
  return AppBar(
    iconTheme: const IconThemeData(color: AppColors.defaultBlack),
    backgroundColor: AppColors.white,
    elevation: 0,
    centerTitle: false,
    title: Text(
      'Daily Progress Report',
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
