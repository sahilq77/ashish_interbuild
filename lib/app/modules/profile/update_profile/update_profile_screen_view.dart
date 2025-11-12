import 'dart:io';
import 'package:ashishinterbuild/app/modules/profile/profile_controller.dart';
import 'package:ashishinterbuild/app/modules/profile/update_profile/update_profile_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart'
    show AppColors, accentOrangeFaded;
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreenView extends StatelessWidget {
  const UpdateProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final UpdateProfileController controller = Get.put(
      UpdateProfileController(),
    );
      
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
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
                        _buildDetailSection(controller),
                        SizedBox(height: ResponsiveHelper.spacing(24)),
                        _buildSaveButton(controller),
                        SizedBox(height: ResponsiveHelper.spacing(32)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ========================================
  // AppBar
  // ========================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Update Profile',
        style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
          fontSize: ResponsiveHelper.getResponsiveFontSize(18),
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.defaultBlack),
        onPressed: () => Get.back(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Divider(color: AppColors.grey.withOpacity(0.5), height: 0),
      ),
    );
  }

  // ========================================
  // Profile Header with Image Picker
  // ========================================
  Widget _buildProfileHeader(UpdateProfileController controller) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Background card
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

            // Profile picture with edit button
            Positioned(
              bottom: -ResponsiveHelper.spacing(50),
              child: Obx(() {
                final String? localPath = controller.user.value?.profileImgPath;
                final String? networkUrl =
                    controller.user.value?.profilePictureUrl;

                return Container(
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
                      // Avatar
                      GestureDetector(
                        onTap: () => controller.showImageSourceSheet(),
                        child: CircleAvatar(
                          radius: ResponsiveHelper.spacing(50),
                          backgroundColor: AppColors.lightGrey,
                          child:
                              localPath != null && File(localPath).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(localPath),
                                    width: ResponsiveHelper.spacing(100),
                                    height: ResponsiveHelper.spacing(100),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : networkUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    networkUrl,
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
                      ),

                      // Edit Camera Icon
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            print("object");
                            controller.showImageSourceSheet();
                          },
                          child: Container(
                            width: ResponsiveHelper.spacing(28),
                            height: ResponsiveHelper.spacing(28),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              border: Border.all(
                                color: AppColors.white,
                                width: 3,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 13,
                              color: AppColors.defaultBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),

        // Name & Greeting
        SizedBox(height: ResponsiveHelper.spacing(60)),
        Obx(
          () => Text(
            'Hi, ${controller.user.value?.name ?? ''}',
            style: AppStyle.heading1PoppinsBlack.responsive.copyWith(
              fontSize: ResponsiveHelper.getResponsiveFontSize(18),
              fontWeight: FontWeight.w600,
            ),
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

  // ========================================
  // Detail Section (Read-only)
  // ========================================
  Widget _buildDetailSection(UpdateProfileController controller) {
    return Container(
      margin: ResponsiveHelper.paddingSymmetric(horizontal: 16),
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ResponsiveHelper.spacing(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlyField(
            label: 'Full Name',
            value: controller.user.value!.name,
          ),
          const Divider(height: 24, thickness: 0.8),
          _buildReadOnlyField(
            label: 'Email',
            value: controller.user.value!.email,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.bodyRegularPoppinsGrey.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(14),
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(4)),
        Text(
          value,
          style: AppStyle.bodyRegularPoppinsBlack.responsive.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(16),
          ),
        ),
      ],
    );
  }

  // ========================================
  // Save Button
  // ========================================
  Widget _buildSaveButton(UpdateProfileController controller) {
    return Padding(
      padding: ResponsiveHelper.paddingSymmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.spacing(16),
            ),
          ),
          onPressed: controller.user.value?.profileImgPath != null
              ? () => controller.updateUser(controller.user.value!)
              : null,
          child: Obx(
            () => controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
