import 'dart:convert';


GetUpdateDPRListResponse getUpdateDprListResponseFromJson(String str) => GetUpdateDPRListResponse.fromJson(json.decode(str));

String getUpdateDprListResponseToJson(GetUpdateDPRListResponse data) => json.encode(data.toJson());

class GetUpdateDPRListResponse {
  bool status;
  dynamic error;
  String message;
  DprData data;

  GetUpdateDPRListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetUpdateDPRListResponse.fromJson(Map<String, dynamic> json) => GetUpdateDPRListResponse(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: DprData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class DprData {
  int draw;
  int recordsTotal;
  int recordsFiltered;
  AppColumnDetails appColumnDetails;
  List<DprItem> data;
  DprCounts? dprCounts;

  DprData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
    this.dprCounts,
  });

  factory DprData.fromJson(Map<String, dynamic> json) => DprData(
    draw: json["draw"] ?? 0,
    recordsTotal: json["recordsTotal"] ?? 0,
    recordsFiltered: json["recordsFiltered"] ?? 0,
    appColumnDetails: AppColumnDetails.fromJson(json["app_column_details"]),
    data: List<DprItem>.from(json["data"].map((x) => DprItem.fromJson(x))),
    dprCounts: json["dpr_counts"] != null ? DprCounts.fromJson(json["dpr_counts"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "app_column_details": appColumnDetails.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    if (dprCounts != null) "dpr_counts": dprCounts!.toJson(),
  };
}

class AppColumnDetails {
  List<String> columns;
  List<String> frontDisplayColumns;
  List<String> frontSecondaryDisplayColumns;
  List<String> buttonDisplayColumn;

  AppColumnDetails({
    required this.columns,
    required this.frontDisplayColumns,
    required this.frontSecondaryDisplayColumns,
    required this.buttonDisplayColumn,
  });

  factory AppColumnDetails.fromJson(Map<String, dynamic> json) => AppColumnDetails(
    columns: List<String>.from(json["columns"].map((x) => x)),
    frontDisplayColumns: List<String>.from(json["front_display_columns"].map((x) => x)),
    frontSecondaryDisplayColumns: List<String>.from(json["front_secondary_display_columns"].map((x) => x)),
    buttonDisplayColumn: List<String>.from(json["button_display_column"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "columns": List<dynamic>.from(columns.map((x) => x)),
    "front_display_columns": List<dynamic>.from(frontDisplayColumns.map((x) => x)),
    "front_secondary_display_columns": List<dynamic>.from(frontSecondaryDisplayColumns.map((x) => x)),
    "button_display_column": List<dynamic>.from(buttonDisplayColumn.map((x) => x)),
  };
}

class DprCounts {
  String projectId;
  String packageId;
  String pboqId;
  int totalMs;
  DprStatus dprStatus;

  DprCounts({
    required this.projectId,
    required this.packageId,
    required this.pboqId,
    required this.totalMs,
    required this.dprStatus,
  });

  factory DprCounts.fromJson(Map<String, dynamic> json) => DprCounts(
    projectId: json["project_id"] ?? "",
    packageId: json["package_id"] ?? "",
    pboqId: json["pboq_id"] ?? "",
    totalMs: json["TotalMs"] ?? 0,
    dprStatus: DprStatus.fromJson(json["dpr_status"]),
  );

  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "package_id": packageId,
    "pboq_id": pboqId,
    "TotalMs": totalMs,
    "dpr_status": dprStatus.toJson(),
  };
}

class DprStatus {
  int target;
  int achievedTarget;
  String targetAmount;
  String achievedTargetAmount;

  DprStatus({
    required this.target,
    required this.achievedTarget,
    required this.targetAmount,
    required this.achievedTargetAmount,
  });

  factory DprStatus.fromJson(Map<String, dynamic> json) => DprStatus(
    target: json["target"] ?? 0,
    achievedTarget: json["achieved_target"] ?? 0,
    targetAmount: json["target_amount"] ?? "0.00",
    achievedTargetAmount: json["achieved_target_amount"] ?? "0.00",
  );

  Map<String, dynamic> toJson() => {
    "target": target,
    "achieved_target": achievedTarget,
    "target_amount": targetAmount,
    "achieved_target_amount": achievedTargetAmount,
  };
}

class DprItem {
  Map<String, dynamic> fields;

  DprItem({required this.fields});

  factory DprItem.fromJson(Map<String, dynamic> json) => DprItem(fields: json);

  Map<String, dynamic> toJson() => fields;

  String getField(String fieldName) {
    return fields[fieldName]?.toString() ?? '';
  }
}