// To parse this JSON data, do
//
//     final getDashboardResponse = getDashboardResponseFromJson(jsonString);

import 'dart:convert';

List<GetWorkFrontUpdateDashboard> geWorkFrontDashboardResponseFromJson(
  String str,
) => List<GetWorkFrontUpdateDashboard>.from(
  json.decode(str).map((x) => GetWorkFrontUpdateDashboard.fromJson(x)),
);

String getWorkFrontDashboardResponseToJson(
  List<GetWorkFrontUpdateDashboard> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWorkFrontUpdateDashboard {
  bool status;
  dynamic error;
  String message;
  int draw;
  int recordsTotal;
  int recordsFiltered;
  WfCounts wfCounts;

  GetWorkFrontUpdateDashboard({
    required this.status,
    required this.error,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.wfCounts,
  });

  factory GetWorkFrontUpdateDashboard.fromJson(Map<String, dynamic> json) =>
      GetWorkFrontUpdateDashboard(
        status: json["status"],
        error: json["error"] ?? "",
        message: json["message"],
        draw: json["data"]?["draw"] ?? 0,
        recordsTotal: json["data"]?["recordsTotal"] ?? 0,
        recordsFiltered: json["data"]?["recordsFiltered"] ?? 0,
        wfCounts: WfCounts.fromJson(json["data"]?["wf_counts"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "wir_counts": wfCounts.toJson(),
  };
}

class WfCounts {
  int totalTarget;
  double totalAchievedTarget;
  double totalAchievedTargetPer;

  WfCounts({
    required this.totalTarget,
    required this.totalAchievedTarget,
    required this.totalAchievedTargetPer,
  });

  factory WfCounts.fromJson(Map<String, dynamic> json) => WfCounts(
    totalTarget: json["total_target"],
    totalAchievedTarget: json["total_achieved_target"]?.toDouble(),
    totalAchievedTargetPer: json["total_achieved_target_per"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "total_target": totalTarget,
    "total_achieved_target": totalAchievedTarget,
    "total_achieved_target_per": totalAchievedTargetPer,
  };
}
