import 'package:ashishinterbuild/app/modules/profile/update_profile/update_profile_controller.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart'
    show AppColors, accentOrangeFaded;
import 'package:ashishinterbuild/app/utils/responsive_utils.dart';
import 'package:ashishinterbuild/app/widgets/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Profile Details',
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

  Widget _buildProfileHeader(UpdateProfileController controller) {
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
                                  child: Image.asset(
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
                        Positioned(
                          bottom: ResponsiveHelper.spacing(0),
                          right: ResponsiveHelper.spacing(0),
                          child: GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                'Info',
                                'Edit Profile Picture not implemented',
                                snackPosition: SnackPosition.BOTTOM,
                              );
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
                              child: Icon(
                                Icons.edit,
                                size: ResponsiveHelper.spacing(13),
                                color: AppColors.defaultBlack,
                              ),
                            ),
                          ),
                        ),
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
          const Divider(),
          _buildReadOnlyField(
            label: 'Email',
            value: controller.user.value!.email,
          ),
          const Divider(),
          _buildReadOnlyField(
            label: 'Phone',
            value: controller.user.value!.phone ?? 'Not provided',
          ),
          const Divider(),
          _buildReadOnlyField(
            label: 'Address',
            value: controller.user.value!.address ?? 'Not provided',
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
}
