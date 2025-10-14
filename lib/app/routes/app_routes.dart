import 'package:ashishinterbuild/app/modules/home/home_binding.dart';
import 'package:ashishinterbuild/app/modules/home/home_screen_view.dart';
import 'package:ashishinterbuild/app/modules/login/login_binding.dart';
import 'package:ashishinterbuild/app/modules/login/login_view.dart';
import 'package:ashishinterbuild/app/modules/measurment_sheet/add_pboq/add_pboq_form_binding.dart';
import 'package:ashishinterbuild/app/modules/measurment_sheet/add_pboq/add_pboq_form_view.dart';
import 'package:ashishinterbuild/app/modules/measurment_sheet/measurment_sheet_binding.dart';
import 'package:ashishinterbuild/app/modules/measurment_sheet/measurment_sheet_view.dart';
import 'package:ashishinterbuild/app/modules/splash/splash_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String measurmentSheetView = '/measurment-sheet-list';
static const String addPBOQ = '/add-pboq';
  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashView()),

    // Add when login module is ready:
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    GetPage(name: home, page: () => const HomeView(), binding: HomeBinding()),

    GetPage(
      name: measurmentSheetView,
      page: () => const MeasurmentSheetView(),
      binding: MeasurmentSheetBinding(),
    ),
  GetPage(
      name: addPBOQ,
      page: () => const AddPboqFormView(),
      binding: AddPboqFormBinding(),
    ),
    
  ];
}



//UI Document https://docs.google.com/document/d/1JTP0ZKcv69bkD-X3slYDCD31zSbO0hea_Ap2l83Zy5Q/edit?tab=t.0