import 'dart:convert';

/// ---------------------------------------------------------------
///  Parse the whole list (your API returns a list with 1 element)
/// ---------------------------------------------------------------
List<GetLoginResponse> getLoginResponseFromJson(String str) =>
    List<GetLoginResponse>.from(
      json.decode(str).map((x) => GetLoginResponse.fromJson(x)),
    );

String getLoginResponseToJson(List<GetLoginResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLoginResponse {
  final bool status;
  final String? error; // <-- now nullable String
  final String message;
  final Data? data; // <-- now nullable Data

  GetLoginResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetLoginResponse.fromJson(Map<String, dynamic> json) =>
      GetLoginResponse(
        status: json["status"] as bool,
        error: json["error"] as String?, // may be null
        message: json["message"] as String,
        data: json["data"] == null
            ? null
            : Data.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final String loginType;
  final String userId;
  final String userRoleId;
  final String isAdminUser;
  final String profilePicPath;
  final List<dynamic> allowedModules;
  final String authToken;

  Data({
    required this.loginType,
    required this.userId,
    required this.userRoleId,
    required this.isAdminUser,
    required this.profilePicPath,
    required this.allowedModules,
    required this.authToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    loginType: json["login_type"]?.toString() ?? "",
    userId: json["user_id"]?.toString() ?? "",
    userRoleId: json["user_role_id"]?.toString() ?? "",
    isAdminUser: json["is_admin_user"]?.toString() ?? "",
    profilePicPath: json["profile_pic_path"]?.toString() ?? "",
    allowedModules: List<dynamic>.from(
      (json["allowed_modules"] as List?) ?? [],
    ),
    authToken: json["auth_token"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "login_type": loginType,
    "user_id": userId,
    "user_role_id": userRoleId,
    "is_admin_user": isAdminUser,
    "profile_pic_path": profilePicPath,
    "allowed_modules": allowedModules,
    "auth_token": authToken,
  };
}
