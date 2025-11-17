// To parse this JSON data, do
//
//     final getDashboardResponse = getDashboardResponseFromJson(jsonString);

import 'dart:convert';

List<GetDashboardResponse> getDashboardResponseFromJson(String str) =>
    List<GetDashboardResponse>.from(
      json.decode(str).map((x) => GetDashboardResponse.fromJson(x)),
    );

String getDashboardResponseToJson(List<GetDashboardResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDashboardResponse {
  bool status;
  dynamic error;
  String message;
  int draw;
  int recordsTotal;
  int recordsFiltered;
  DprCounts dprCounts;

  GetDashboardResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.dprCounts,
  });

  factory GetDashboardResponse.fromJson(Map<String, dynamic> json) =>
      GetDashboardResponse(
        status: json["status"],
        error: json["error"] ?? "",
        message: json["message"],
        draw: json["data"]?["draw"] ?? 0,
        recordsTotal: json["data"]?["recordsTotal"] ?? 0,
        recordsFiltered: json["data"]?["recordsFiltered"] ?? 0,
        dprCounts: DprCounts.fromJson(json["data"]?["dpr_counts"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "dpr_counts": dprCounts.toJson(),
  };
}

class DprCounts {
  String totalTarget;
  String totalAchievedTarget;
  String totalAchievedTargetPer;
  String monthTarget;
  String monthAchievedTarget;
  String monthAchievedTargetPer;
  String weeklyTarget;
  String weeklyAchievedTarget;
  String weeklyAchievedTargetPer;
  String todayTarget;
  String todayAchievedTarget;
  String todayAchievedTargetPer;

  DprCounts({
    required this.totalTarget,
    required this.totalAchievedTarget,
    required this.totalAchievedTargetPer,
    required this.monthTarget,
    required this.monthAchievedTarget,
    required this.monthAchievedTargetPer,
    required this.weeklyTarget,
    required this.weeklyAchievedTarget,
    required this.weeklyAchievedTargetPer,
    required this.todayTarget,
    required this.todayAchievedTarget,
    required this.todayAchievedTargetPer,
  });

  factory DprCounts.fromJson(Map<String, dynamic> json) => DprCounts(
    totalTarget: json["total_target"]?.toString() ?? "",
    totalAchievedTarget: json["total_achieved_target"]?.toString() ?? "",
    totalAchievedTargetPer: json["total_achieved_target_per"]?.toString() ?? "",
    monthTarget: json["month_target"]?.toString() ?? "",
    monthAchievedTarget: json["month_achieved_target"]?.toString() ?? "",
    monthAchievedTargetPer: json["month_achieved_target_per"]?.toString() ?? "",
    weeklyTarget: json["weekly_target"]?.toString() ?? "",
    weeklyAchievedTarget: json["weekly_achieved_target"]?.toString() ?? "",
    weeklyAchievedTargetPer: json["weekly_achieved_target_per"]?.toString() ?? "",
    todayTarget: json["today_target"]?.toString() ?? "",
    todayAchievedTarget: json["today_achieved_target"]?.toString() ?? "",
    todayAchievedTargetPer: json["today_achieved_target_per"]?.toString() ?? "",
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
    "today_target": todayTarget,
    "today_achieved_target": todayAchievedTarget,
    "today_achieved_target_per": todayAchievedTargetPer,
  };
}
