// To parse this JSON data, do
//
//     final getDashboardResponse = getDashboardResponseFromJson(jsonString);

import 'dart:convert';

List<GetWeeklyDashboard> getWeeeklyDashboardResponseFromJson(String str) =>
    List<GetWeeklyDashboard>.from(
      json.decode(str).map((x) => GetWeeklyDashboard.fromJson(x)),
    );

String getWeeeklyDashboardResponseToJson(List<GetWeeklyDashboard> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWeeklyDashboard {
  bool status;
  dynamic error;
  String message;
  int draw;
  int recordsTotal;
  int recordsFiltered;
  WirCounts wirCounts;

  GetWeeklyDashboard({
    required this.status,
    required this.error,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.wirCounts,
  });

  factory GetWeeklyDashboard.fromJson(Map<String, dynamic> json) =>
      GetWeeklyDashboard(
        status: json["status"],
        error: json["error"] ?? "",
        message: json["message"],
        draw: json["data"]?["draw"] ?? 0,
        recordsTotal: json["data"]?["recordsTotal"] ?? 0,
        recordsFiltered: json["data"]?["recordsFiltered"] ?? 0,
        wirCounts: WirCounts.fromJson(json["data"]?["wir_counts"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "wir_counts": wirCounts.toJson(),
  };
}

class WirCounts {
  int totalTarget;
  int totalAchievedTarget;
  String totalAchievedTargetPer;
  int monthTarget;
  int monthAchievedTarget;
  String monthAchievedTargetPer;
  int weeklyTarget;
  int weeklyAchievedTarget;
  String weeklyAchievedTargetPer;

  WirCounts({
    required this.totalTarget,
    required this.totalAchievedTarget,
    required this.totalAchievedTargetPer,
    required this.monthTarget,
    required this.monthAchievedTarget,
    required this.monthAchievedTargetPer,
    required this.weeklyTarget,
    required this.weeklyAchievedTarget,
    required this.weeklyAchievedTargetPer,
  });

  factory WirCounts.fromJson(Map<String, dynamic> json) => WirCounts(
    totalTarget: json["total_target"] ?? 0,
    totalAchievedTarget: json["total_achieved_target"] ?? 0,
    totalAchievedTargetPer: json["total_achieved_target_per"] ?? "",
    monthTarget: json["month_target"] ?? 0,
    monthAchievedTarget: json["month_achieved_target"] ?? 0,
    monthAchievedTargetPer: json["month_achieved_target_per"] ?? "",
    weeklyTarget: json["weekly_target"] ?? 0,
    weeklyAchievedTarget: json["weekly_achieved_target"] ?? 0,
    weeklyAchievedTargetPer: json["weekly_achieved_target_per"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "total_target": totalTarget,
    "total_achieved_target": totalAchievedTarget,
    "total_achieved_target_per": totalAchievedTargetPer,
    "month_target": monthTarget,
    "month_achieved_target": monthAchievedTarget,
    "month_achieved_target_per": monthAchievedTargetPer,
    "weekly_target": weeklyTarget,
    "weekly_achieved_target": weeklyAchievedTarget,
    "weekly_achieved_target_per": weeklyAchievedTargetPer,
  };
}
