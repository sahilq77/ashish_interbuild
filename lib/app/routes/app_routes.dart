import 'package:ashishinterbuild/app/modules/home/acc/acc_binding.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_project_name_list/acc_project_list/acc_project_list.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_project_name_list/acc_project_list/acc_project_list_binding.dart';
import 'package:ashishinterbuild/app/modules/home/acc/acc_screen_view.dart';
import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_binding.dart';
import 'package:ashishinterbuild/app/modules/home/acc/add_acc/add_acc_form_view.dart';
import 'package:ashishinterbuild/app/modules/home/acc/update_acc/update_acc_form_binding.dart';
import 'package:ashishinterbuild/app/modules/home/acc/update_acc/update_acc_form_view.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/add_client_commitment/add_client_commitment_form_binding.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/add_client_commitment/add_client_commitment_form_view.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_binding.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_project_list/client_commitment_project.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_project_list/client_commitment_project_binding.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/client_commitment_screen.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/update_client_commitment/update_client_commitment_form_binding.dart';
import 'package:ashishinterbuild/app/modules/home/client_commitment/update_client_commitment/update_client_commitment_form_view.dart';
import 'package:ashishinterbuild/app/modules/profile/profile_binding.dart';
import 'package:ashishinterbuild/app/modules/profile/profile_screen_view.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_dashboard/daily_progress_report_dashboard_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/daily_progress_report_view.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/dpr_project_list/dpr_project_list.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/dpr_project_list/dpr_project_list_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/update_progress_report_list/update_progress_report_binding.dart';
import 'package:ashishinterbuild/app/modules/home/daily_progress_report/update_progress_report_list/update_progress_report_list.dart';
import 'package:ashishinterbuild/app/modules/home/home_binding.dart';
import 'package:ashishinterbuild/app/modules/home/home_screen_view.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_project_name/measurment_project_name_binding.dart';
import 'package:ashishinterbuild/app/modules/home/measurment_sheet/measurment_project_name/measurment_project_name_list.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/update_weekly_inspection_list/update_weekly_inspection_binding.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/update_weekly_inspection_list/update_weekly_inspection_list.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_binding.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_project_list/weekly_inspection_project_list.dart';
import 'package:ashishinterbuild/app/modules/home/weekly_work_inspection/weekly_inspection/weekly_inspection_project_list/weekly_inspection_project_list_binding.dart';
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
import 'package:ashishinterbuild/app/modules/notification/notification_binding.dart';
import 'package:ashishinterbuild/app/modules/notification/notification_view.dart';
import 'package:ashishinterbuild/app/modules/profile/update_profile/update_profile_binding.dart';
import 'package:ashishinterbuild/app/modules/profile/update_profile/update_profile_screen_view.dart';
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
  static const String measurmentProjectNameList =
      '/measurment-projectName-list';
  static const String notifications = '/notifications';
  static const String dprProjectList = '/dpr-project-list';
  static const String weeklyInspectionProjectList =
      '/weekly-inspection-project-list';
  static const String profile = '/profile';
  static const String accProjects = '/acc-projects';
  static const String accScreenList = '/acc-list';
  static const String addAccForm = '/add-acc-form';
  static const String updateAccForm = '/update-acc-form';
  static const String clientCommitmentProject = '/client-commitment-project';
  static const String clientCommitmentList = '/client-commitment-list';
  static const String addClientCommitment = '/add-client-commitment';
  static const String updateClientCommitment = '/update-client-commitment';
  static const String updateProfile = '/update-profile';

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
    GetPage(
      name: measurmentProjectNameList,
      page: () => const MeasurmentProjectNameList(),
      binding: MeasurmentProjectNameBinding(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: dprProjectList,
      page: () => const DprProjectList(),
      binding: DprProjectListBinding(),
    ),
    GetPage(
      name: weeklyInspectionProjectList,
      page: () => const WeeklyInspectionProjectList(),
      binding: WeeklyInspectionProjectListBinding(),
    ),

    GetPage(
      name: profile,
      page: () => const ProfileScreenView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: accProjects,
      page: () => const AccProjectList(),
      binding: AccProjectListBinding(),
    ),

    GetPage(
      name: accScreenList,
      page: () => const AccScreenView(),
      binding: AccBinding(),
    ),

    GetPage(
      name: addAccForm,
      page: () => const AddAccIssueFormView(),
      binding: AddAccFormBinding(),
    ),

    GetPage(
      name: updateAccForm,
      page: () => const UpdateAccFormView(),
      binding: UpdateAccFormBinding(),
    ),
    GetPage(
      name: clientCommitmentProject,
      page: () => const ClientCommitmentProject(),
      binding: ClientCommitmentProjectBinding(),
    ),
    GetPage(
      name: clientCommitmentList,
      page: () => const ClientCommitmentScreen(),
      binding: ClientCommitmentBinding(),
    ),

    GetPage(
      name: addClientCommitment,
      page: () => const AddClientCommitmentFormView(),
      binding: AddClientCommitmentFormBinding(),
    ),
    GetPage(
      name: updateClientCommitment,
      page: () => const UpdateClientCommitmentFormView(),
      binding: UpdateClientCommitmentFormBinding(),
    ),
    GetPage(
      name: updateProfile,
      page: () => const UpdateProfileScreenView(),
      binding: UpdateProfileBinding(),
    ),
  ];
}



//UI Document https://docs.google.com/document/d/1JTP0ZKcv69bkD-X3slYDCD31zSbO0hea_Ap2l83Zy5Q/edit?tab=t.0