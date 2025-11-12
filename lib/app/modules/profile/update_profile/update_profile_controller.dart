import 'dart:io';

import 'package:ashishinterbuild/app/data/models/profile/get_profile_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/networkutility.dart';
import 'package:ashishinterbuild/app/modules/profile/profile_controller.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_colors.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:ashishinterbuild/app/widgets/app_snackbar_styles.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateProfileController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final RxBool isLoading = true.obs;
  final ImagePicker _picker = ImagePicker();
  final ProfileController refreshontroller = Get.put(ProfileController());
  @override
  void onInit() {
    super.onInit();
    // fetchUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserProfile(
        context: Get.context!,
      ); // Fetch user profile on initialization
    });
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  var userProfileList = <UserProfile>[].obs;
  var errorMessages = ''.obs;

  RxString imageLink = "".obs;

  // // Method to set the selected user
  // void setSelectedUser(UserProfile user) {
  //   selectedUser.value = user;
  // }

  // // Method to clear the selected user
  // void clearSelectedUser() {
  //   selectedUser.value = null;
  // }

  // Method to fetch user profile
  Future<void> fetchUserProfile({
    required BuildContext context,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) {
        userProfileList.clear(); // Clear existing data on refresh
      }

      final jsonBody = {
        // "user_id": AppUtility.userID,
        // "user_type": AppUtility.userType,
      };

      List<GetUserProfileResponse>? response =
          (await Networkcall().getMethod(
                Networkutility.getProfileApi,
                Networkutility.getProfile,

                context,
              ))
              as List<GetUserProfileResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == true) {
          final users = response[0].data;
          user.value = User(
            id: users.roleId,
            name: users.userName,
            email: users.emailId,
            profilePictureUrl: users.profileImg,
          );
          refreshontroller.fetchUserProfile(context: context, isRefresh: true);
        } else {
          errorMessage.value =
              'Failed to load profile: ${response[0].message ?? 'Unknown error'}';
        }
      } else {
        errorMessage.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
    } on ParseException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestImagePermission(ImageSource source) async {
    late Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // Android 13+ uses granular media permissions
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permission = Permission.photos; // READ_MEDIA_IMAGES
        } else {
          permission = Permission.storage; // Legacy
        }
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true; // iOS: isLimited means user selected some photos
    }

    if (status.isDenied) {
      Get.snackbar(
        'Permission Required',
        'Please grant permission to access ${source == ImageSource.camera ? 'camera' : 'gallery'}.',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Denied',
        'Please enable permission from settings.',
        snackPosition: SnackPosition.TOP,
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text(
            'Open Settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return false;
    }

    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    final hasPermission = await requestImagePermission(source);
    if (!hasPermission) return;

    try {
      // ---- 1. Use allowedExtensions (gallery only) ----
      final Map<String, dynamic> extra = source == ImageSource.gallery
          ? {
              'allowedExtensions': ['jpg', 'jpeg'],
            } // <-- ONLY JPG/JPEG
          : {};

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        // imageQuality: 85,
        // maxWidth: 800,
        // ...extra,                     // spread the map only for gallery
      );

      if (pickedFile == null) return;

      // ---- 2. Double-check the extension (works on every platform) ----
      final String path = pickedFile.path;
      final String ext = path.split('.').last.toLowerCase();

      if (ext != 'jpg' && ext != 'jpeg') {
        AppSnackbarStyles.showError(
          title: 'Invalid format',
          message: "Please select a JPG or JPEG image.",
        );

        return;
      }

      // ---- 3. Update the user model ----
      user.value = user.value?.copyWith(profileImgPath: path);
      imageLink.value = path;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // -----------------------------------------------------------------
  // 2. Update profile (multipart)
  // -----------------------------------------------------------------
  Future<void> updateUser(User user) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.updateUserDetail),
      );

      // Text fields
      request.fields['person_name'] = user.name;
      request.fields['contact_no'] = "7777";

      // ---- Profile image (if selected) ----
      if (user.profileImgPath != null &&
          File(user.profileImgPath!).existsSync()) {
        final file = await http.MultipartFile.fromPath(
          'profile_img',
          user.profileImgPath!,
          // contentType: MediaType('image', 'jpeg'), // most cameras return jpeg
        );
        request.files.add(file);
      }

      // Auth header
      request.headers['Authorization'] = 'Bearer ${AppUtility.authToken}';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value = 'Profile updated successfully!';
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: successMessage.value,
        );

        // Refresh profile after success
        await fetchUserProfile(context: Get.context!);
      } else if (response.statusCode == 401) {
        await AppUtility.clearUserInfo();
        Get.offAllNamed(AppRoutes.login);
        errorMessage.value =
            'Failed: ${response.statusCode} – ${response.body}';

        // Get.snackbar(
        //   'Error',
        //   errorMessage.value,
        //   snackPosition: SnackPosition.TOP,
        // );
      } else {
        errorMessage.value =
            'Failed: ${response.statusCode} – ${response.body}';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    } catch (e) {
      errorMessage.value = 'Exception: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------------------------------------------
  // 3. Helper to show picker bottom-sheet
  // -----------------------------------------------------------------
  void showImageSourceSheet(
    BuildContext context,
    UpdateProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 16,
                  ),
                  child: Wrap(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.photo,
                              size: 40,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Edit Profile Photo',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF36322E),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Choose a method to update your photo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        pickImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.orange.shade100,
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 28,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        pickImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.orange.shade100,
                                        child: Icon(
                                          Icons.photo_library,
                                          size: 28,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
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
            );
          },
        );
      },
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  // NEW – path of the image that will be uploaded
  String? profileImgPath;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.profileImgPath,
  });

  // Helper to create a copy with a new path
  User copyWith({String? profileImgPath}) {
    return User(
      id: id,
      name: name,
      email: email,
      profilePictureUrl: profilePictureUrl,
      profileImgPath: profileImgPath ?? this.profileImgPath,
    );
  }
}
