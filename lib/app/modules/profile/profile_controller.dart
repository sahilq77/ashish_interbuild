import 'package:ashishinterbuild/app/data/models/profile/profile_model.dart';
import 'package:ashishinterbuild/app/routes/app_routes.dart';
import 'package:ashishinterbuild/app/utils/app_images.dart';
import 'package:ashishinterbuild/app/utils/app_utility.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Reactive variables
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUser();
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

  // Mock fetching user data (replace with actual API call or local storage)
  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      user.value = const User(
        id: '1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        profilePictureUrl: AppImages.profile, // No profile picture for now
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Handle logout logic (replace with actual auth service logout)
  Future<void> logout() async {
    try {
      // Simulate logout process
      await Future.delayed(const Duration(seconds: 1));
      // Navigate to login screen and remove all previous routes
      await AppUtility.clearUserInfo();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
