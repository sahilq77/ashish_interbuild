import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_view.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/update_progress_report_list/update_progress_report_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/update_progress_report_list/update_progress_report_list.dart';
import 'package:ashishinterbuild/app/modules/home/home_binding.dart';
import 'package:ashishinterbuild/app/modules/home/home_screen_view.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/update_weekly_inspection_list/update_weekly_inspection_binding.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/update_weekly_inspection_list/update_weekly_inspection_list.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_binding.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_view.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_work_inspection_dashboard/weekly_inspection_dashboard.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_work_inspection_dashboard/weekly_inspection_dashboard_binding.dart';
import 'package:ashishinterbuild/app/modules/login/login_binding.dart';
import 'package:ashishinterbuild/app/modules/login/login_view.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/deduction_form/deduction_form_binding.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/deduction_form/deduction_form_controller.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/deduction_form/deduction_form_view.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_details_list.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/pboq_measurment_details_list/pboq_measurment_details_list_binding.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/add_pboq/add_pboq_form_binding.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/add_pboq/add_pboq_form_view.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_binding.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_sheet_view.dart';
import 'package:ashishinterbuild/app/modules/splash/splash_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String measurmentSheetView = '/measurment-sheet-list';
  static const String addPBOQ = '/add-pboq';
  static const String pboqList = '/pboq-list';
  static const String deductionForm = '/deduction-form';
  static const String dailyProgressReport = '/daily-progress-report';
  static const String updateDailyReportList =
      '/update-daily-progress-report-list';
  static const String dailyProgressDashboard = '/daily-progress-dashboard';
  static const String weeklyInspectionDashboard =
      '/weekly-inspection-dashboard';
  static const String weeklyInspection = '/weekly-inspection';
  static const String updateWeeklyInspection = '/update-weekly-inspection';

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
    GetPage(
      name: pboqList,
      page: () => const PboqMeasurmentDetailsList(),
      binding: PboqMeasurmentDetailsListBinding(),
    ),
    GetPage(
      name: deductionForm,
      page: () => const DeductionFormView(),
      binding: DeductionFormBinding(),
    ),
    GetPage(
      name: dailyProgressReport,
      page: () => const DailyProgressReportViiew(),
      binding: DailyProgressReportBinding(),
    ),
    GetPage(
      name: updateDailyReportList,
      page: () => const UpdateProgressReportList(),
      binding: UpdateProgressReportBinding(),
    ),
    GetPage(
      name: dailyProgressDashboard,
      page: () => const DailyProgressReportDashboard(),
      binding: DailyProgressReportDashboardBinding(),
    ),
    GetPage(
      name: weeklyInspectionDashboard,
      page: () => const WeeklyInspectionDashboard(),
      binding: WeeklyInspectionDashboardBinding(),
    ),
    GetPage(
      name: weeklyInspection,
      page: () => const WeeklyInspectionView(),
      binding: WeeklyInspectionBinding(),
    ),
    GetPage(
      name: updateWeeklyInspection,
      page: () => const UpdateWeeklyInspectionList(),
      binding: UpdateWeeklyInspectionBinding(),
    ),
  ];
}



//UI Document https://docs.google.com/document/d/1JTP0ZKcv69bkD-X3slYDCD31zSbO0hea_Ap2l83Zy5Q/edit?tab=t.0