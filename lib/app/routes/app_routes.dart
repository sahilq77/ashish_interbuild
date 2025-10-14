import 'package:ashishinterbuild/app/modules/home/home_binding.dart';
import 'package:ashishinterbuild/app/modules/home/home_screen_view.dart';
import 'package:ashishinterbuild/app/modules/login/login_binding.dart';
import 'package:ashishinterbuild/app/modules/login/login_view.dart';
import 'package:ashishinterbuild/app/modules/splash/splash_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashView()),

    // Add when login module is ready:
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    GetPage(name: home, page: () => const HomeView(), binding: HomeBinding()),
  ];
}



//UI Document https://docs.google.com/document/d/1JTP0ZKcv69bkD-X3slYDCD31zSbO0hea_Ap2l83Zy5Q/edit?tab=t.0