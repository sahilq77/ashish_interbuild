class Networkutility {
  static String baseUrl = "https://seekhelp.in/ashish-interbuild/api/site/";

  static String login = "${baseUrl + "login"}";
  static int loginApi = 1;

  static String getProfile = "${baseUrl + "profile/details"}";
  static int getProfileApi = 2;

  static String updateUserDetail = "${baseUrl + "profile/update"}";
  static int updateUserDetailApi = 3;

  static String getProjectNameList = "${baseUrl + "projects"}";
  static int getProjectNameListApi = 4;

  static String getPackagesList = "${baseUrl + "packages"}";
  static int getPackagesListApi = 5;

  static String getPboq = "${baseUrl + "pboq"}";
  static int getPboqApi = 6;

  static String getZones = "${baseUrl + "zones"}";
  static int getZonesApi = 7;

  static String getZoneLocations = "${baseUrl + "zone-locations"}";
  static int getZoneLocationsApi = 8;

  static String getPboqList = "${baseUrl + "ms/pboq-list"}";
  static int getPboqListApi = 9;

  static String getPboqMeasurmentSheetList = "${baseUrl + "ms/list"}";
  static int getPboqMeasurmentSheetListApi = 10;

  static String addMeasurementSheet = "${baseUrl + "ms/add"}";
  static int addMeasurementSheetApi = 11;

  static String getPlanningStatus = "${baseUrl + "ms/zone-status"}";
  static int getPlanningStatusApi = 12;

  static String editMeasurementSheet = "${baseUrl + "ms/update"}";
  static int editMeasurementSheetApi = 13;

  static String deleteMeasurementSheet = "${baseUrl + "ms/delete"}";
  static int deleteMeasurementSheetApi = 14;

  static String pboqDeductionsList = "${baseUrl + "ms/pboq-deductions"}";
  static int pboqDeductionsListApi = 15;

  static String addDeductions = "${baseUrl + "ms/add-deduction"}";
  static int addDeductionsApi = 16;

  //<======================= DPR MODULE ============================>

  static String getDPRdashboard = "${baseUrl + "dpr/list"}";
  static int getDPRdashboardApi = 17;

  static String getDPRList = "${baseUrl + "dpr/list"}";
  static int getDPRListApi = 18;

  static String getDprReportDetailList = "${baseUrl + "dpr/details"}";
  static int getDprReportDetailListApi = 19;

  static String updateDailyProgressReport = "${baseUrl + "dpr/update"}";
  static int updateDailyProgressReportApi = 21;

  //<======================= WEEKLY INSPECTION MODULE ============================>
  static String getWIRdashboard = "${baseUrl + "wir/list"}";
  static int getWIRdashboardApi = 22;

  static String getWIRList = "${baseUrl + "wir/list"}";
  static int getWIRListApi = 23;

  static String getWeekPeriods = "${baseUrl + "week-periods"}";
  static int getWeekPeriodsApi = 24;

  static String getWirDetailList = "${baseUrl + "wir/details"}";
  static int getWirDetailListApi = 25;

  static String updateWIR = "${baseUrl + "wir/update"}";
  static int updateWIRApi = 26;

  //<======================= WORK FRONT UPDATE MODULE ============================>
  static String getWFUdashboard = "${baseUrl + "wf/list"}";
  static int getWFUdashboardApi = 27;

  static String getWFUList = "${baseUrl + "wf/list"}";
  static int getWFUListApi = 28;

  static String getWFUDetailList = "${baseUrl + "wf/details"}";
  static int getWFUDetailListApi = 29;

  static String wfuUpdate = "${baseUrl + "wf/update"}";
  static int wfuUpdateApi = 30;

  //<======================= ACC MODULE ============================>
  static String getACCList = "${baseUrl + "acc/list"}";
  static int getACCListApi = 31;

  static String getProjectNameDropdown = "${baseUrl + "projects"}";
  static int getProjectNameDropdownApi = 32;
}


//<======================= API DOCUMENT ============================>

//https://seekhelp.in/ashish-interbuild/api-docs#