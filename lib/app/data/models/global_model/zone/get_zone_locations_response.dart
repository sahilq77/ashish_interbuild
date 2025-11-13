// To parse this JSON data, do
//
//     final getZoneLocationsResponse = getZoneLocationsResponseFromJson(jsonString);

import 'dart:convert';

List<GetZoneLocationsResponse> getZoneLocationsResponseFromJson(String str) =>
    List<GetZoneLocationsResponse>.from(
      json.decode(str).map((x) => GetZoneLocationsResponse.fromJson(x)),
    );

String getZoneLocationsResponseToJson(List<GetZoneLocationsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetZoneLocationsResponse {
  bool status;
  dynamic error;
  String message;
  List<ZoneLocationData> data;

  GetZoneLocationsResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetZoneLocationsResponse.fromJson(Map<String, dynamic> json) =>
      GetZoneLocationsResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<ZoneLocationData>.from(
          json["data"].map((x) => ZoneLocationData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ZoneLocationData {
  String zoneLocationId;
  String locationName;
  String zoneId;
  String zoneName;
  String projectId;
  String projectCode;
  String projectName;

  ZoneLocationData({
    required this.zoneLocationId,
    required this.locationName,
    required this.zoneId,
    required this.zoneName,
    required this.projectId,
    required this.projectCode,
    required this.projectName,
  });

  factory ZoneLocationData.fromJson(Map<String, dynamic> json) =>
      ZoneLocationData(
        zoneLocationId: json["zone_location_id"] ?? "",
        locationName: json["location_name"] ?? "",
        zoneId: json["zone_id"] ?? "",
        zoneName: json["zone_name"] ?? "",
        projectId: json["project_id"] ?? "",
        projectCode: json["project_code"] ?? "",
        projectName: json["project_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "zone_location_id": zoneLocationId,
    "location_name": locationName,
    "zone_id": zoneId,
    "zone_name": zoneName,
    "project_id": projectId,
    "project_code": projectCode,
    "project_name": projectName,
  };
}
