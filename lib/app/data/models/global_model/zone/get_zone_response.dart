// To parse this JSON data, do
//
//     final getZoneResponse = getZoneResponseFromJson(jsonString);

import 'dart:convert';

List<GetZoneResponse> getZoneResponseFromJson(String str) =>
    List<GetZoneResponse>.from(
      json.decode(str).map((x) => GetZoneResponse.fromJson(x)),
    );

String getZoneResponseToJson(List<GetZoneResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetZoneResponse {
  bool status;
  dynamic error;
  String message;
  List<ZoneData> data;

  GetZoneResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetZoneResponse.fromJson(Map<String, dynamic> json) =>
      GetZoneResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<ZoneData>.from(
          json["data"].map((x) => ZoneData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ZoneData {
  String zoneId;
  String zoneName;
  String projectId;
  String projectCode;
  String projectName;

  ZoneData({
    required this.zoneId,
    required this.zoneName,
    required this.projectId,
    required this.projectCode,
    required this.projectName,
  });

  factory ZoneData.fromJson(Map<String, dynamic> json) => ZoneData(
    zoneId: json["zone_id"] ?? "",
    zoneName: json["zone_name"] ?? "",
    projectId: json["project_id"] ?? "",
    projectCode: json["project_code"] ?? "",
    projectName: json["project_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "zone_id": zoneId,
    "zone_name": zoneName,
    "project_id": projectId,
    "project_code": projectCode,
    "project_name": projectName,
  };
}
