// To parse this JSON data, do
//
//     final getProjectNameResponse = getProjectNameResponseFromJson(jsonString);

import 'dart:convert';

List<GetProjectNameResponse> getProjectNameResponseFromJson(String str) =>
    List<GetProjectNameResponse>.from(
      json.decode(str).map((x) => GetProjectNameResponse.fromJson(x)),
    );

String getProjectNameResponseToJson(List<GetProjectNameResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetProjectNameResponse {
  bool status;
  dynamic error;
  String message;
  List<ProjectData> data;

  GetProjectNameResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetProjectNameResponse.fromJson(Map<String, dynamic> json) =>
      GetProjectNameResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<ProjectData>.from(
          json["data"].map((x) => ProjectData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ProjectData {
  String projectId;
  String projectCode;
  String projectName;
  String clientName;
  String projectRoles;

  ProjectData({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.clientName,

    required this.projectRoles,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) => ProjectData(
    projectId: json["project_id"] ?? "",
    projectCode: json["project_code"] ?? "",
    projectName: json["project_name"] ?? "",
    clientName: json["client_name"] ?? "",

    projectRoles: json["project_roles"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "project_code": projectCode,
    "project_name": projectName,
    "client_name": clientName,

    "project_roles": projectRoles,
  };
}
