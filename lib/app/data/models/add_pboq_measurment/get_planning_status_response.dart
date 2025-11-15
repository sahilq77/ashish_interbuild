// To parse this JSON data, do
//
//     final getPlanningStatusResponse = getPlanningStatusResponseFromJson(jsonString);

import 'dart:convert';

List<GetPlanningStatusResponse> getPlanningStatusResponseFromJson(String str) =>
    List<GetPlanningStatusResponse>.from(
      json.decode(str).map((x) => GetPlanningStatusResponse.fromJson(x)),
    );

String getPlanningStatusResponseToJson(List<GetPlanningStatusResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPlanningStatusResponse {
  bool status;
  dynamic error;
  String message;
  List<PlanningStatus> data;

  GetPlanningStatusResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetPlanningStatusResponse.fromJson(Map<String, dynamic> json) =>
      GetPlanningStatusResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<PlanningStatus>.from(
          json["data"].map((x) => PlanningStatus.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PlanningStatus {
  int zoneId;
  String qty;
  String status;
  String plannedQty;
  String existingMsQty;
  String newMsQty;
  String pendingMsQty;

  PlanningStatus({
    required this.zoneId,
    required this.qty,
    required this.status,
    required this.plannedQty,
    required this.existingMsQty,
    required this.newMsQty,
    required this.pendingMsQty,
  });

  factory PlanningStatus.fromJson(Map<String, dynamic> json) => PlanningStatus(
    zoneId: json["zone_id"] ?? 0,
    qty: json["qty"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
    plannedQty: json["planned_qty"]?.toString() ?? "",
    existingMsQty: json["existing_ms_qty"]?.toString() ?? "",
    newMsQty: json["new_ms_qty"]?.toString() ?? "",
    pendingMsQty: json["pending_ms_qty"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "zone_id": zoneId,
    "qty": qty,
    "status": status,
    "planned_qty": plannedQty,
    "existing_ms_qty": existingMsQty,
    "new_ms_qty": newMsQty,
    "pending_ms_qty": pendingMsQty,
  };
}
