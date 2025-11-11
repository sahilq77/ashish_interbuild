// Updated lib/utils/app_utility.dart (assuming this path based on imports)
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtility {
  static String? userID;
  static String? fullName;
  static String? logintype;

  static String? mobileNumber;
  static String? email;
  static String? plantId;
  static RxString plantName = ''.obs;
  static String? userRoleId;
  static String? isAdminUser;
  static bool isLoggedIn = false;
  static List<String> allowedModules = [];
  static String? authToken;
  // static bool hasSeenOnboarding = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    // hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (isLoggedIn) {
      fullName = prefs.getString('full_name');
      mobileNumber = prefs.getString('mobile_number');
      email = prefs.getString('email');
      plantId = prefs.getString('plant_id');
      plantName.value = prefs.getString('plant_name') ?? '';
      userID = prefs.getString('login_user_id');
      userRoleId = prefs.getString('user_role_id');
      isAdminUser = prefs.getString('is_admin_user');
      allowedModules = prefs.getStringList('allowed_modules') ?? [];
      authToken = prefs.getString('auth_token');
    }
  }

  static Future<void> setUserInfo(
    String name,
    String mobile,
    String emailid,
    String userid,
    String plantid,
    String role,
    String isadmin,
    List<String> modules,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('full_name', name);
    await prefs.setString('mobile_number', mobile);
    await prefs.setString('email', emailid);
    await prefs.setString('login_user_id', userid);
    await prefs.setString('plant_id', plantid);
    await prefs.setString('plant_name', '');
    await prefs.setString('user_role_id', role);
    await prefs.setString('is_admin_user', isadmin);
    await prefs.setStringList('allowed_modules', modules);
    await prefs.setString('auth_token', token);
    
    isAdminUser = isadmin;
    authToken = token;
    allowedModules = modules;
    fullName = name;
    mobileNumber = mobile;
    userID = userid;
    email = emailid;
    plantId = plantid;
    userRoleId = role;
    plantName.value = '';
    isLoggedIn = true;
  }

  static Future<void> updatePlant(String plantid, String plantname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plant_id', plantid);
    await prefs.setString('plant_name', plantname);
    plantId = plantid;
    plantName.value = plantname;
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('full_name');
    await prefs.remove('mobile_number');
    await prefs.remove('email');
    await prefs.remove('login_user_id');
    await prefs.remove('plant_id');
    await prefs.remove('plant_name');
    await prefs.remove('user_role');
    await prefs.remove('is_admin_user');
    await prefs.remove('allowed_modules');
    await prefs.remove('auth_token');
    isAdminUser = null;
    authToken = null;
    allowedModules = [];
    userID = null;
    fullName = null;
    mobileNumber = null;
    email = null;
    plantId = null;
    userRoleId = null;
    plantName.value = '';
    isLoggedIn = false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    // hasSeenOnboarding = true;
  }

  // OPTIONAL: Add this static getter for cleaner access (not required, but aligns with previous suggestion)
  static bool get isUserLoggedIn => isLoggedIn;
  // static bool get isOnboardingCompleted => hasSeenOnboarding;
}
