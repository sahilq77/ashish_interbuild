// To parse this JSON data, do
//
//     final getMilestoneResponse = getMilestoneResponseFromJson(jsonString);

import 'dart:convert';

List<GetMilestoneResponse> getMilestoneResponseFromJson(String str) => List<GetMilestoneResponse>.from(json.decode(str).map((x) => GetMilestoneResponse.fromJson(x)));

String getMilestoneResponseToJson(List<GetMilestoneResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMilestoneResponse {
    bool status;
    dynamic error;
    String message;
    List<Datum> data;

    GetMilestoneResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetMilestoneResponse.fromJson(Map<String, dynamic> json) => GetMilestoneResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String milestoneId;
    String descr;
    DateTime milestoneTargetDate;

    Datum({
        required this.milestoneId,
        required this.descr,
        required this.milestoneTargetDate,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        milestoneId: json["milestone_id"],
        descr: json["descr"],
        milestoneTargetDate: DateTime.parse(json["milestone_target_date"]),
    );

    Map<String, dynamic> toJson() => {
        "milestone_id": milestoneId,
        "descr": descr,
        "milestone_target_date": "${milestoneTargetDate.year.toString().padLeft(4, '0')}-${milestoneTargetDate.month.toString().padLeft(2, '0')}-${milestoneTargetDate.day.toString().padLeft(2, '0')}",
    };
}
