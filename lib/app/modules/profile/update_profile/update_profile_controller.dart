import 'dart:io';

import 'package:ashishinterbuild/app/data/models/profile/get_profile_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/networkutility.dart';
import 'package:ashishinterbuild/app/modules/profile/profile_controller.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserProfile(context: Get.context!);
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

  // -----------------------------------------------------------------
  // 1. Fetch user profile
  // -----------------------------------------------------------------
  Future<void> fetchUserProfile({
    required BuildContext context,
    bool isRefresh = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isRefresh) userProfileList.clear();

      final jsonBody = {};

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
          AppSnackbarStyles.showError(
            title: 'Profile Error',
            message: errorMessage.value,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Network Error',
          message: errorMessage.value,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'HTTP Error',
        message: errorMessage.value,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Parse Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(
        title: 'Unexpected',
        message: errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------------------------------------------
  // Permission handling
  // -----------------------------------------------------------------
  Future<bool> requestImagePermission(ImageSource source) async {
    late Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        permission = androidInfo.version.sdkInt >= 33
            ? Permission.photos
            : Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.request();

    if (status.isGranted || status.isLimited) return true;

    if (status.isDenied) {
      AppSnackbarStyles.showWarning(
        title: 'Permission Required',
        message:
            'Please grant permission to access ${source == ImageSource.camera ? 'camera' : 'gallery'}.',
      );
      return false;
    }

    if (status.isPermanentlyDenied) {
      AppSnackbarStyles.showError(
        title: 'Permission Denied',
        message: 'Please enable permission from settings.',
      );
      // Optional: add a button to open settings (you can keep openAppSettings())
      return false;
    }

    return false;
  }

  // -----------------------------------------------------------------
  // Pick image
  // -----------------------------------------------------------------
  Future<void> pickImage(ImageSource source) async {
    final hasPermission = await requestImagePermission(source);
    if (!hasPermission) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        user.value = user.value?.copyWith(profileImgPath: pickedFile.path);
        imageLink.value = pickedFile.path;
      }
    } catch (e) {
      AppSnackbarStyles.showError(
        title: 'Image Error',
        message: 'Failed to pick image: $e',
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

      request.fields['person_name'] = user.name;
      request.fields['contact_no'] = "7777";

      if (user.profileImgPath != null &&
          File(user.profileImgPath!).existsSync()) {
        final file = await http.MultipartFile.fromPath(
          'profile_img',
          user.profileImgPath!,
        );
        request.files.add(file);
      }

      request.headers['Authorization'] = 'Bearer ${AppUtility.authToken}';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value = 'Profile updated successfully!';
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: successMessage.value,
        );
        await fetchUserProfile(context: Get.context!);
      } else {
        errorMessage.value =
            'Failed: ${response.statusCode} – ${response.body}';
        AppSnackbarStyles.showError(
          title: 'Update Failed',
          message: errorMessage.value,
        );
      }
    } catch (e) {
      errorMessage.value = 'Exception: $e';
      AppSnackbarStyles.showError(
        title: 'Exception',
        message: errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------------------------------------------
  // 3. Show image source bottom sheet
  // -----------------------------------------------------------------
  void showImageSourceSheet() {
    Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Get.back();
              pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Get.back();
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancel'),
            onTap: () => Get.back(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}

// -----------------------------------------------------------------
// User model (unchanged)
// -----------------------------------------------------------------
class User {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  String? profileImgPath;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.profileImgPath,
  });

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
