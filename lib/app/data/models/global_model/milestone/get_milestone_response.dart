// To parse this JSON data, do
//
//     final getMilestoneResponse = getMilestoneResponseFromJson(jsonString);

import 'dart:convert';

List<GetMilestoneResponse> getMilestoneResponseFromJson(String str) =>
    List<GetMilestoneResponse>.from(
      json.decode(str).map((x) => GetMilestoneResponse.fromJson(x)),
    );

String getMilestoneResponseToJson(List<GetMilestoneResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMilestoneResponse {
  bool status;
  dynamic error;
  String message;
  List<MilestoneData> data;

  GetMilestoneResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetMilestoneResponse.fromJson(Map<String, dynamic> json) =>
      GetMilestoneResponse(
        status: json["status"],
        error: json["error"] ?? "",
        message: json["message"] ?? "",
        data: List<MilestoneData>.from(
          json["data"].map((x) => MilestoneData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MilestoneData {
  String milestoneId;
  String descr;

  MilestoneData({required this.milestoneId, required this.descr});

  factory MilestoneData.fromJson(Map<String, dynamic> json) => MilestoneData(
    milestoneId: json["milestone_id"] ?? "",
    descr: json["descr"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "milestone_id": milestoneId,
    "descr": descr,
  };
}
