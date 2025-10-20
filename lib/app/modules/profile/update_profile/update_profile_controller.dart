import 'package:ashishinterbuild/app/data/models/profile/profile_model.dart';
import 'package:ashishinterbuild/app/utils/app_images.dart';
import 'package:get/get.dart';

class UpdateProfileController extends GetxController {
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

  // Fetch user data (mock, replace with actual API call)
  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      user.value = User(
        id: '1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1 123-456-7890',
        address: '123 Main St, City, Country',
        profilePictureUrl: AppImages.profile,
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
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? profilePictureUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.profilePictureUrl,
  });
}
