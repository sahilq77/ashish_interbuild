// To parse this JSON data, do
//
//     final getUserProfileResponse = getUserProfileResponseFromJson(jsonString);

import 'dart:convert';

List<GetUserProfileResponse> getUserProfileResponseFromJson(String str) => List<GetUserProfileResponse>.from(json.decode(str).map((x) => GetUserProfileResponse.fromJson(x)));

String getUserProfileResponseToJson(List<GetUserProfileResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetUserProfileResponse {
    bool status;
    dynamic error;
    String message;
    UserProfile data;

    GetUserProfileResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetUserProfileResponse.fromJson(Map<String, dynamic> json) => GetUserProfileResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: UserProfile.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": data.toJson(),
    };
}

class UserProfile {
    String empCode;
    String personName;
    String contactNo;
    String emailId;
    String userName;
    String profileImg;
    String password;
    String roleId;
    String hodPersonName;
    String hodEmpCode;
    dynamic reportingToPersonName;
    dynamic reportingToEmpCode;
    String departmentName;
    String designationName;
    String roleName;
    List<dynamic> allowedModulesData;

    UserProfile({
        required this.empCode,
        required this.personName,
        required this.contactNo,
        required this.emailId,
        required this.userName,
        required this.profileImg,
        required this.password,
        required this.roleId,
        required this.hodPersonName,
        required this.hodEmpCode,
        required this.reportingToPersonName,
        required this.reportingToEmpCode,
        required this.departmentName,
        required this.designationName,
        required this.roleName,
        required this.allowedModulesData,
    });

    factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        empCode: json["emp_code"]??"",
        personName: json["person_name"]??"",
        contactNo: json["contact_no"]??"",
        emailId: json["email_id"]??"",
        userName: json["user_name"]??"",
        profileImg: json["profile_img"]??"",
        password: json["password"]??"",
        roleId: json["role_id"]??"",
        hodPersonName: json["hod_person_name"]??"",
        hodEmpCode: json["hod_emp_code"]??"",
        reportingToPersonName: json["reporting_to_person_name"]??"",
        reportingToEmpCode: json["reporting_to_emp_code"]??"",
        departmentName: json["department_name"]??"",
        designationName: json["designation_name"]??"",
        roleName: json["role_name"]??"",
        allowedModulesData: List<dynamic>.from(json["allowed_modules_data"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "emp_code": empCode,
        "person_name": personName,
        "contact_no": contactNo,
        "email_id": emailId,
        "user_name": userName,
        "profile_img": profileImg,
        "password": password,
        "role_id": roleId,
        "hod_person_name": hodPersonName,
        "hod_emp_code": hodEmpCode,
        "reporting_to_person_name": reportingToPersonName,
        "reporting_to_emp_code": reportingToEmpCode,
        "department_name": departmentName,
        "designation_name": designationName,
        "role_name": roleName,
        "allowed_modules_data": List<dynamic>.from(allowedModulesData.map((x) => x)),
    };
}
