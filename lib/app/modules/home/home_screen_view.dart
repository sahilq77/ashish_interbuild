import 'dart:ui'; // Added for ImageFilter
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
    ResponsiveHelper.init(context);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ---------- WAVE BACKGROUND ----------

          // ---------- MAIN CONTENT ----------
          SafeArea(
            child: Padding(
              padding: ResponsiveHelper.padding(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPadding + 12),

                  // ---------- HERO TITLE ----------
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      "Welcome back!",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(26),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      "Select a module to continue",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(16),
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- GRID ----------
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                        mainAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _gridItems.length,
                      itemBuilder: (context, index) {
                        final item = _gridItems[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: _buildGlassCard(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MARK: - AppBar
  // -------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.red,
              width: 1.2,
            ), // Added red border
          ),
          child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
        ),
      ),
      title: Text(
        'Ashish Interbuild',
        style: AppStyle.heading1PoppinsWhite.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: AppColors.white, // Set drawer icon color to white
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
        // IconButton(
        //   icon: const Icon(Icons.logout_rounded, color: AppColors.white),
        //   onPressed: _showLogoutDialog,
        // ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MARK: - Logout Dialog
  // -------------------------------------------------------------------------
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await AppUtility.clearUserInfo();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // MARK: - Grid Data Model
  // -------------------------------------------------------------------------
  static const List<GridItem> _gridItems = [
    GridItem(
      title: 'Measurement Sheet',
      route: AppRoutes.measurmentSheetView,
      gradientColor: Color.fromARGB(255, 132, 0, 255),
      icon: FontAwesomeIcons.solidHourglassHalf,
    ),
    GridItem(
      title: 'Daily Progress Report (DPR)',
      route: AppRoutes.dailyProgressDashboard,
      gradientColor: Color.fromARGB(255, 255, 0, 162),
      icon: FontAwesomeIcons.solidClock,
    ),
    GridItem(
      title: 'Weekly Inspection',
      route: AppRoutes.weeklyInspectionDashboard,
      gradientColor: Color.fromARGB(255, 0, 165, 253),
      icon: FontAwesomeIcons.userSlash,
    ),
    GridItem(
      title: 'Access and Manage (ACC)',
      route: null,
      gradientColor: Color.fromARGB(255, 253, 135, 0),
      icon: FontAwesomeIcons.userSlash,
    ),
    GridItem(
      title: 'Client Commitment (CC)',
      route: null,
      gradientColor: Color.fromARGB(255, 0, 102, 255),
      icon: FontAwesomeIcons.solidClock,
    ),
  ];

  // -------------------------------------------------------------------------
  // MARK: - Glass Card
  // -------------------------------------------------------------------------
  Widget _buildGlassCard(GridItem item) {
    return GestureDetector(
      onTap: item.route != null ? () => Get.toNamed(item.route!) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Set solid white background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red, // Keep red border
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              // Optional subtle inner glow (can be removed if not needed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 36,
                        color: Colors.red, // Keep red icon
                      ),
                      const SizedBox(height: 20),
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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
      ),
    );
  }
}

// -------------------------------------------------------------------------
// MARK: - Simple Data Class
// -------------------------------------------------------------------------
class GridItem {
  final String title;
  final String? route;
  final Color gradientColor;
  final IconData icon;

  const GridItem({
    required this.title,
    this.route,
    required this.gradientColor,
    required this.icon,
  });
}
