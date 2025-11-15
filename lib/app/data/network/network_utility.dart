class Networkutility {
  static String baseUrl = "https://seekhelp.in/ashish-interbuild/api/site/";

  static String login = "${baseUrl + "login"}";
  static int loginApi = 1;

  static String getProfile = "${baseUrl + "user-details"}";
  static int getProfileApi = 2;

  static String updateUserDetail = "${baseUrl + "update-user-details"}";
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

  static String getPboqList = "${baseUrl + "pboq-list"}";
  static int getPboqListApi = 9;

  static String getPboqMeasurmentSheetList = "${baseUrl + "pboq-ms"}";
  static int getPboqMeasurmentSheetListApi = 10;

  static String addMeasurementSheet = "${baseUrl + "add-ms"}";
  static int addMeasurementSheetApi = 11;

  static String getPlanningStatus = "${baseUrl + "zone-ms-status"}";
  static int getPlanningStatusApi = 12;

  static String editMeasurementSheet = "${baseUrl + "update-ms"}";
  static int editMeasurementSheetApi = 13;

  static String deleteMeasurementSheet = "${baseUrl + "delete-ms"}";
  static int deleteMeasurementSheetApi = 14;

  static String pboqDeductionsList = "${baseUrl + "pboq-deductions"}";
  static int pboqDeductionsListApi = 15;
}


//<======================= API DOCUMENT ============================>

//https://seekhelp.in/ashish-interbuild/api-docs#