// To parse this JSON data, do
//
//     final getLoginResponse = getLoginResponseFromJson(jsonString);

import 'dart:convert';

List<GetLoginResponse> getLoginResponseFromJson(String str) => List<GetLoginResponse>.from(json.decode(str).map((x) => GetLoginResponse.fromJson(x)));

String getLoginResponseToJson(List<GetLoginResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLoginResponse {
    bool status;
    dynamic error;
    String message;
    Data data;

    GetLoginResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetLoginResponse.fromJson(Map<String, dynamic> json) => GetLoginResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String loginType;
    String userId;
    String userRoleId;
    String isAdminUser;
    String profilePicPath;
    List<dynamic> allowedModules;
    String authToken;

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
        loginType: json["login_type"]??"",
        userId: json["user_id"]??"",
        userRoleId: json["user_role_id"]??"",
        isAdminUser: json["is_admin_user"]??"",
        profilePicPath: json["profile_pic_path"]??"",
        allowedModules: List<dynamic>.from(json["allowed_modules"].map((x) => x)),
        authToken: json["auth_token"]??"",
    );

    Map<String, dynamic> toJson() => {
        "login_type": loginType,
        "user_id": userId,
        "user_role_id": userRoleId,
        "is_admin_user": isAdminUser,
        "profile_pic_path": profilePicPath,
        "allowed_modules": List<dynamic>.from(allowedModules.map((x) => x)),
        "auth_token": authToken,
    };
}
