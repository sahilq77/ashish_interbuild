// To parse this JSON data, do
//
//     final getProjectDropdownResponse = getProjectDropdownResponseFromJson(jsonString);

import 'dart:convert';

List<GetProjectDropdownResponse> getProjectDropdownResponseFromJson(
  String str,
) => List<GetProjectDropdownResponse>.from(
  json.decode(str).map((x) => GetProjectDropdownResponse.fromJson(x)),
);

String getProjectDropdownResponseToJson(
  List<GetProjectDropdownResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetProjectDropdownResponse {
  bool status;
  dynamic error;
  String message;
  List<ProjectData> data;

  GetProjectDropdownResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetProjectDropdownResponse.fromJson(Map<String, dynamic> json) =>
      GetProjectDropdownResponse(
        status: json["status"],
        error: json["error"] ?? "",
        message: json["message"] ?? "",
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

  ProjectData({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) => ProjectData(
    projectId: json["project_id"] ?? "",
    projectCode: json["project_code"] ?? "",
    projectName: json["project_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "project_code": projectCode,
    "project_name": projectName,
  };
}
