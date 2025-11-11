import 'package:ashishinterbuild/app/modules/bottom_navigation/botttom_navigation_controller.dart';
import 'package:ashishinterbuild/app/modules/bottom_navigation/cutom_bottom_bar.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_style.dart';
import '../../widgets/app_button_style.dart';
import 'profile_controller.dart';

class ProfileScreenView extends StatelessWidget {
  const ProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final ProfileController controller = Get.put(ProfileController());
    final bottomController = Get.put(BottomNavigationController());
    ResponsiveHelper.init(context);
    return PopScope(
      canPop: false, // Prevent default back navigation
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Call the same onWillPop logic from BottomNavigationController
          bool shouldPop = await bottomController.onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppbar(),
        body: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.user.value == null
              ? Center(
                  child: Text(
                    'No user data available',
                    style: AppStyle.bodyRegularPoppinsGrey,
                  ),
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: ResponsiveHelper.spacing(24)),
                          _buildProfileHeader(controller),
                          SizedBox(height: ResponsiveHelper.spacing(24)),
                          Container(
                            margin: ResponsiveHelper.paddingSymmetric(
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.spacing(16),
                              ),
                            ),
                            child: Padding(
                              padding: ResponsiveHelper.paddingSymmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      Get.toNamed(AppRoutes.updateProfile);
                                    },

                                    leading: Icon(FontAwesomeIcons.user),
                                    title: Text(
                                      "Update Profile",
                                      style: AppStyle.bodyRegularPoppinsBlack,
                                    ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: AppColors.grey,
                                      size: ResponsiveHelper.spacing(24),
                                    ),
                                  ),
                                  Divider(),
                                  ListTile(
                                    onTap: () {
                                      Get.toNamed(AppRoutes.notifications);
                                    },
                                    leading: Icon(FontAwesomeIcons.bell),
                                    title: Text(
                                      "Notification",
                                      style: AppStyle.bodyRegularPoppinsBlack,
                                    ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: AppColors.grey,
                                      size: ResponsiveHelper.spacing(24),
                                    ),
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      FontAwesomeIcons.signOut,
                                      color: AppColors.primary,
                                    ),
                                    title: Text(
                                      "Log Out",
                                      style: AppStyle.bodyRegularPoppinsPrimary,
                                    ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: AppColors.grey,
                                      size: ResponsiveHelper.spacing(24),
                                    ),
                                    onTap: () =>
                                        _showLogoutDialog(context, controller),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(24)),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: CustomBottomBar(),
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
        'Profile',
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

  Widget _buildProfileHeader(ProfileController controller) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: double.infinity,
              height: ResponsiveHelper.spacing(140),
              margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.faded,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.spacing(16),
                ),
              ),
            ),
            Positioned(
              bottom: -ResponsiveHelper.spacing(50),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: ResponsiveHelper.spacing(50),
                          backgroundColor: AppColors.lightGrey,
                          child:
                              controller.user.value!.profilePictureUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    controller.user.value!.profilePictureUrl!,
                                    width: ResponsiveHelper.spacing(100),
                                    height: ResponsiveHelper.spacing(100),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 55,
                                              color: AppColors.grey,
                                            ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: AppColors.grey,
                                ),
                        ),
                        // Positioned(
                        //   bottom: ResponsiveHelper.spacing(4),
                        //   right: ResponsiveHelper.spacing(4),
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       Get.snackbar(
                        //         'Info',
                        //         'Edit Profile Picture not implemented',
                        //         snackPosition: SnackPosition.BOTTOM,
                        //       );
                        //     },
                        //     child: Container(
                        //       width: ResponsiveHelper.spacing(32),
                        //       height: ResponsiveHelper.spacing(32),
                        //       decoration: BoxDecoration(
                        //         color: AppColors.white,
                        //         shape: BoxShape.circle,
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.black.withOpacity(0.1),
                        //             blurRadius: 4,
                        //             offset: const Offset(0, 2),
                        //           ),
                        //         ],
                        //       ),
                        //       child: Icon(
                        //         Icons.edit,
                        //         size: ResponsiveHelper.spacing(16),
                        //         color: AppColors.defaultBlack,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.spacing(60)),
        Text(
          'Hi, ${controller.user.value!.name}',
          style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(4)),
        Text(
          controller.greeting,
          style: AppStyle.bodySmallPoppinsGrey.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(13),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Log Out',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(18),
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.getResponsiveFontSize(14),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: AppButtonStyles.outlinedSmallBlack(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: AppStyle.labelPrimaryPoppinsBlack,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.elevatedSmallBlack(),
                    onPressed: () {
                      controller.logout();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Log Out',
                      style: AppStyle.labelPrimaryPoppinsWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
