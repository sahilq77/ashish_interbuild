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
}
