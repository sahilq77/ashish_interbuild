// To parse this JSON data, do
//
//     final getDoerRoleResponse = getDoerRoleResponseFromJson(jsonString);

import 'dart:convert';

List<GetDoerRoleResponse> getDoerRoleResponseFromJson(String str) => List<GetDoerRoleResponse>.from(json.decode(str).map((x) => GetDoerRoleResponse.fromJson(x)));

String getDoerRoleResponseToJson(List<GetDoerRoleResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDoerRoleResponse {
    bool status;
    dynamic error;
    String message;
    List<DoerRoleData> data;

    GetDoerRoleResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetDoerRoleResponse.fromJson(Map<String, dynamic> json) => GetDoerRoleResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<DoerRoleData>.from(json["data"].map((x) => DoerRoleData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class DoerRoleData {
    String doerRoleId;
    String roleName;

    DoerRoleData({
        required this.doerRoleId,
        required this.roleName,
    });

    factory DoerRoleData.fromJson(Map<String, dynamic> json) => DoerRoleData(
        doerRoleId: json["doer_role_id"]??"",
        roleName: json["role_name"]??"",
    );

    Map<String, dynamic> toJson() => {
        "doer_role_id": doerRoleId,
        "role_name": roleName,
    };
}
