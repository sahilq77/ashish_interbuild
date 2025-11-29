import 'dart:ui';
import 'package:ashishinterbuild/app/modules/bottom_navigation/botttom_navigation_controller.dart';
import 'package:ashishinterbuild/app/modules/bottom_navigation/cutom_bottom_bar.dart';
import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/app_images.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bottomController = Get.put(BottomNavigationController());
    ResponsiveHelper.init(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          bool shouldPop = await bottomController.onWillPop();
          if (shouldPop && context.mounted) {
            bottomController.onWillPop();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Header
              Padding(
                padding: ResponsiveHelper.padding(16),
                child: _buildHeader(),
              ),
              Divider(height: 1, color: AppColors.lightGrey.withOpacity(0.3)),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.padding(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveHelper.spacing(16)),

                      // Hero Title
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          "Dashboard Overview",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              26,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          "Track your projects and metrics",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              16,
                            ),
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dashboard Cards
                      _buildDashboardCard(
                        title: 'Measurement Sheet',
                        icon: AppImages.measurmentIcon,
                        color: const Color(0xFF8400FF),
                        route: AppRoutes.measurmentProjectNameList,
                        metrics: [],
                        index: 0,
                      ),

                      _buildDashboardCard(
                        title: 'Daily Progress Report (DPR)',
                        icon: AppImages.dprIcon,
                        color: const Color(0xFFFF00A2),
                        route: AppRoutes.dprProjectList,
                        metrics: [
                          MetricItem(
                            label: 'Today\'s Target',
                            value: '12 Items',
                            icon: Icons.today_outlined,
                          ),
                          MetricItem(
                            label: 'Weekly Target',
                            value: '85 Items',
                            icon: Icons.calendar_view_week_outlined,
                          ),
                          MetricItem(
                            label: 'Monthly Target',
                            value: '340 Items',
                            icon: Icons.calendar_month_outlined,
                          ),
                        ],
                        index: 1,
                      ),

                      _buildDashboardCard(
                        title: 'Weekly Inspection',
                        icon: AppImages.inspectionIcon,
                        color: const Color(0xFF00A5FD),
                        route: AppRoutes.weeklyInspectionProjectList,
                        metrics: [
                          MetricItem(
                            label: 'Weekly Target',
                            value: '24 Items',
                            icon: Icons.calendar_view_week_outlined,
                          ),
                          MetricItem(
                            label: 'Monthly Target',
                            value: '96 Items',
                            icon: Icons.calendar_month_outlined,
                          ),
                        ],
                        index: 2,
                      ),

                      _buildDashboardCard(
                        title: 'JMR',
                        icon: AppImages.accIcon,
                        color: const Color(0xFFFF6B00),
                        route: null,
                        metrics: [
                          MetricItem(
                            label: 'Pending Value',
                            value: '₹2,45,000',
                            icon: Icons.pending_actions_outlined,
                          ),
                        ],
                        index: 3,
                      ),

                      _buildDashboardCard(
                        title: 'Client Commitment (CC)',
                        icon: AppImages.clientIcon,
                        color: const Color(0xFF0066FF),
                        route: AppRoutes.clientCommitmentProject,
                        metrics: [
                          MetricItem(
                            label: 'Pending Points',
                            value: '8 Items',
                            icon: Icons.list_alt_outlined,
                          ),
                          MetricItem(
                            label: 'CC Approval Pending',
                            value: '3 Items',
                            icon: Icons.approval_outlined,
                          ),
                        ],
                        index: 4,
                      ),

                      _buildDashboardCard(
                        title: 'Work Front Update (WFU)',
                        icon: AppImages.clientIcon,
                        color: const Color(0xFF00C853),
                        route: AppRoutes.workFrontUpdateProjectList,
                        metrics: [
                          MetricItem(
                            label: 'Total Amount',
                            value: '₹12,50,000',
                            icon: Icons.attach_money_outlined,
                          ),
                          MetricItem(
                            label: 'Total Rec Amount',
                            value: '₹8,75,000',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          MetricItem(
                            label: 'Total Rec Percent',
                            value: '70%',
                            icon: Icons.pie_chart_outline,
                          ),
                        ],
                        index: 5,
                      ),

                      _buildDashboardCard(
                        title: 'Access and Manage (ACC)',
                        icon: AppImages.accIcon,
                        color: const Color(0xFFFD8700),
                        route: AppRoutes.accScreenList,
                        metrics: [
                          MetricItem(
                            label: 'My Pending ACC',
                            value: '5 Items',
                            icon: Icons.pending_outlined,
                          ),
                        ],
                        index: 6,
                      ),

                      SizedBox(height: ResponsiveHelper.spacing(20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.spacing(44),
          height: ResponsiveHelper.spacing(44),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              AppImages.appLogo,
              height: ResponsiveHelper.spacing(24),
              width: ResponsiveHelper.spacing(24),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveHelper.safeText(
                "Ashish Interbuild",
                style: AppStyle.bodyBoldPoppinsBlack.responsive.copyWith(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.spacing(12)),
        Container(
          width: ResponsiveHelper.spacing(40),
          height: ResponsiveHelper.spacing(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              FontAwesomeIcons.bell,
              color: AppColors.defaultBlack,
              size: 18,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.notifications);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String icon,
    required Color color,
    required String? route,
    required List<MetricItem> metrics,
    required int index,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: GestureDetector(
        onTap: route != null ? () => Get.toNamed(route) : null,
        child: Container(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Header with white background
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.lightGrey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon container with solid white background
                      Container(
                        width: ResponsiveHelper.spacing(50),
                        height: ResponsiveHelper.spacing(50),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red, width: 1.2),
                        ),
                        padding: EdgeInsets.all(ResponsiveHelper.spacing(12)),
                        child: SvgPicture.asset(icon, fit: BoxFit.contain),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(14)),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              15,
                            ),
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.95),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (route != null)
                        Container(
                          padding: EdgeInsets.all(ResponsiveHelper.spacing(6)),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),

                // Metrics with white background
                if (metrics.isNotEmpty)
                  Container(
                    color: AppColors.white,
                    padding: EdgeInsets.all(ResponsiveHelper.spacing(16)),
                    child: Column(
                      children: metrics.asMap().entries.map((entry) {
                        int idx = entry.key;
                        MetricItem metric = entry.value;
                        bool isLast = idx == metrics.length - 1;

                        return Container(
                          margin: EdgeInsets.only(
                            bottom: isLast ? 0 : ResponsiveHelper.spacing(12),
                          ),
                          padding: EdgeInsets.all(ResponsiveHelper.spacing(12)),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  ResponsiveHelper.spacing(6),
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  metric.icon,
                                  size: 16,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.spacing(10)),
                              Expanded(
                                child: Text(
                                  metric.label,
                                  style: GoogleFonts.poppins(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          13,
                                        ),
                                    color: Colors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                metric.value,
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        13,
                                      ),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MetricItem {
  final String label;
  final String value;
  final IconData icon;

  MetricItem({required this.label, required this.value, required this.icon});
}