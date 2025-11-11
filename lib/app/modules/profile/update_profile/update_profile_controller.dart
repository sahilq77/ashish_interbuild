import 'package:ashishinterbuild/app/data/models/profile/get_profile_response.dart';
import 'package:ashishinterbuild/app/data/network/exceptions.dart';
import 'package:ashishinterbuild/app/data/network/networkcall.dart';
import 'package:ashishinterbuild/app/data/network/networkutility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = true.obs;

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
  var errorMessage = ''.obs;

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
}

class User {
  final String id;
  final String name;
  final String email;
  // final String? phone;
  // final String? address;
  final String? profilePictureUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    // this.phone,
    // this.address,
    this.profilePictureUrl,
  });
}
