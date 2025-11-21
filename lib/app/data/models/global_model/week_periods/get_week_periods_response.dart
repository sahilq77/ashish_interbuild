// To parse this JSON data, do
//
//     final getWeeklyPeriodsResponse = getWeeklyPeriodsResponseFromJson(jsonString);

import 'dart:convert';

List<GetWeeklyPeriodsResponse> getWeeklyPeriodsResponseFromJson(String str) =>
    List<GetWeeklyPeriodsResponse>.from(
      json.decode(str).map((x) => GetWeeklyPeriodsResponse.fromJson(x)),
    );

String getWeeklyPeriodsResponseToJson(List<GetWeeklyPeriodsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWeeklyPeriodsResponse {
  bool status;
  dynamic error;
  String message;
  List<WeeklyPeriod> data;

  GetWeeklyPeriodsResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetWeeklyPeriodsResponse.fromJson(Map<String, dynamic> json) =>
      GetWeeklyPeriodsResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<WeeklyPeriod>.from(json["data"].map((x) => WeeklyPeriod.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class WeeklyPeriod {
  String weekCode;
  String label;
  DateTime weekFromDate;
  DateTime weekToDate;

  WeeklyPeriod({
    required this.weekCode,
    required this.label,
    required this.weekFromDate,
    required this.weekToDate,
  });

  factory WeeklyPeriod.fromJson(Map<String, dynamic> json) => WeeklyPeriod(
    weekCode: json["weekCode"] ?? "",
    label: json["label"] ?? "",
    weekFromDate: DateTime.parse(json["week_from_date"]),
    weekToDate: DateTime.parse(json["week_to_date"]),
  );

  Map<String, dynamic> toJson() => {
    "weekCode": weekCode,
    "label": label,
    "week_from_date":
        "${weekFromDate.year.toString().padLeft(4, '0')}-${weekFromDate.month.toString().padLeft(2, '0')}-${weekFromDate.day.toString().padLeft(2, '0')}",
    "week_to_date":
        "${weekToDate.year.toString().padLeft(4, '0')}-${weekToDate.month.toString().padLeft(2, '0')}-${weekToDate.day.toString().padLeft(2, '0')}",
  };
}
