// To parse this JSON data, do
//
//     final getPackageNameResponse = getPackageNameResponseFromJson(jsonString);

import 'dart:convert';

List<GetPackageNameResponse> getPackageNameResponseFromJson(String str) =>
    List<GetPackageNameResponse>.from(
      json.decode(str).map((x) => GetPackageNameResponse.fromJson(x)),
    );

String getPackageNameResponseToJson(List<GetPackageNameResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPackageNameResponse {
  bool status;
  dynamic error;
  String message;
  List<PackageData> data;

  GetPackageNameResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetPackageNameResponse.fromJson(Map<String, dynamic> json) =>
      GetPackageNameResponse(
        status: json["status"],
        error: json["error"] ?? "",
        message: json["message"],
        data: List<PackageData>.from(
          json["data"].map((x) => PackageData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PackageData {
  String packageId;
  String packageName;
  String projectId;
  String projectCode;
  String projectName;
  String packageValue;

  PackageData({
    required this.packageId,
    required this.packageName,
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.packageValue,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) => PackageData(
    packageId: json["package_id"] ?? "",
    packageName: json["package_name"] ?? "",
    projectId: json["project_id"] ?? "",
    projectCode: json["project_code"] ?? "",
    projectName: json["project_name"] ?? "",
    packageValue: json["package_value"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "package_id": packageId,
    "package_name": packageName,
    "project_id": projectId,
    "project_code": projectCode,
    "project_name": projectName,
    "package_value": packageValue,
  };
}
