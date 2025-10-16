// lib/app/modules/home/home_view.dart
import 'package:ashishinterbuild/app/modules/home/home_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      backgroundColor: AppColors.white,
      //drawer: Drawer(),
      appBar: _buildAppbar(),

      body: Padding(
        padding: ResponsiveHelper.padding(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  _sectionTitle("Critical Operation Analysis"),
            //Divider(),
            SizedBox(height: ResponsiveHelper.screenHeight * 0.01),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
              mainAxisSpacing: ResponsiveHelper.screenWidth * 0.04,
              childAspectRatio: 1.1,
              children: [
                _buildGridItem(
                  'Measurement Sheet',
                  "",
                  () {
                    Get.toNamed(AppRoutes.measurmentSheetView);
                  },
                  const Color.fromARGB(255, 132, 0, 255),
                  FontAwesomeIcons.solidHourglassHalf,
                ),
                _buildGridItem(
                  'Daily Progress Report (DPR)',
                  "",
                  () {
                    Get.toNamed(AppRoutes.dailyProgressDashboard);
                  },
                  const Color.fromARGB(255, 255, 0, 162),
                  FontAwesomeIcons.solidClock,
                ),
                _buildGridItem(
                  'Weekly Inspection',
                  "",
                  () {
                    Get.toNamed(AppRoutes.weeklyInspectionDashboard);
                  },
                  const Color.fromARGB(255, 0, 165, 253),
                  FontAwesomeIcons.userSlash,
                ),
                _buildGridItem(
                  'ACC',
                  "",
                  () {},
                  const Color.fromARGB(255, 253, 135, 0),
                  FontAwesomeIcons.userSlash,
                ),
                _buildGridItem(
                  'CC',
                  "",
                  () {},
                  const Color.fromARGB(255, 0, 102, 255),
                  FontAwesomeIcons.solidClock,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Text _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.grey,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }

  Widget _buildGridItem(
    String title,
    String count,
    VoidCallback onTap,
    Color gradientColor,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColor.withOpacity(0.9),
              gradientColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.white.withOpacity(0.95)),
                  const SizedBox(height: 8),
                  Text(
                    count,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.accentSecondaryPoppinsBlack,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
        'Dashboard',
        style: AppStyle.heading1PoppinsWhite.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Show logout confirmation dialog
            showDialog(
              context: context, // Ensure context is available in your widget
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        AppUtility.clearUserInfo().then(
                          (val) => Get.offAllNamed(AppRoutes.login),
                        ); // Call the logout function
                      },
                      child: Text("Logout"),
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}
