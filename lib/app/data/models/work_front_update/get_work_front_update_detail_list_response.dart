import 'dart:convert';

GetUpdateWorkFrontUpdateListResponse
getUpdateWorkFrontUpdateListResponseFromJson(String str) =>
    GetUpdateWorkFrontUpdateListResponse.fromJson(json.decode(str));

String getUpdateWorkFrontUpdateListResponseToJson(
  GetUpdateWorkFrontUpdateListResponse data,
) => json.encode(data.toJson());

class GetUpdateWorkFrontUpdateListResponse {
  bool status;
  dynamic error;
  String message;
  WorkFrontUpdateData data;

  GetUpdateWorkFrontUpdateListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetUpdateWorkFrontUpdateListResponse.fromJson(
    Map<String, dynamic> json,
  ) => GetUpdateWorkFrontUpdateListResponse(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: WorkFrontUpdateData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class WorkFrontUpdateData {
  int draw;
  int recordsTotal;
  int recordsFiltered;
  AppColumnDetails appColumnDetails;
  List<WorkFrontUpdateItem> data;
  // WorkFrontUpdateCounts? workFrontUpdateCounts;

  WorkFrontUpdateData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
    // this.workFrontUpdateCounts,
  });

  factory WorkFrontUpdateData.fromJson(
    Map<String, dynamic> json,
  ) => WorkFrontUpdateData(
    draw: json["draw"] ?? 0,
    recordsTotal: json["recordsTotal"] ?? 0,
    recordsFiltered: json["recordsFiltered"] ?? 0,
    appColumnDetails: AppColumnDetails.fromJson(json["app_column_details"]),
    data: List<WorkFrontUpdateItem>.from(
      json["data"].map((x) => WorkFrontUpdateItem.fromJson(x)),
    ),
    // workFrontUpdateCounts: json["work_front_update_counts"] != null
    //     ? WorkFrontUpdateCounts.fromJson(json["work_front_update_counts"])
    //     : null,
  );

  Map<String, dynamic> toJson() => {
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "app_column_details": appColumnDetails.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    // if (workFrontUpdateCounts != null)
    //   "wf_count": workFrontUpdateCounts!.toJson(),
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

  factory AppColumnDetails.fromJson(Map<String, dynamic> json) =>
      AppColumnDetails(
        columns: List<String>.from(json["columns"].map((x) => x)),
        frontDisplayColumns: List<String>.from(
          json["front_display_columns"].map((x) => x),
        ),
        frontSecondaryDisplayColumns: List<String>.from(
          json["front_secondary_display_columns"].map((x) => x),
        ),
        buttonDisplayColumn: List<String>.from(
          json["button_display_column"].map((x) => x),
        ),
      );

  Map<String, dynamic> toJson() => {
    "columns": List<dynamic>.from(columns.map((x) => x)),
    "front_display_columns": List<dynamic>.from(
      frontDisplayColumns.map((x) => x),
    ),
    "front_secondary_display_columns": List<dynamic>.from(
      frontSecondaryDisplayColumns.map((x) => x),
    ),
    "button_display_column": List<dynamic>.from(
      buttonDisplayColumn.map((x) => x),
    ),
  };
}

// class WorkFrontUpdateCounts {
//   dynamic projectId;
//   String packageId;
//   String pboqId;
//   int totalMs;
//   WorkFrontUpdateStatus workFrontUpdateStatus;

//   WorkFrontUpdateCounts({
//     required this.projectId,
//     required this.packageId,
//     required this.pboqId,
//     required this.totalMs,
//     required this.workFrontUpdateStatus,
//   });

//   factory WorkFrontUpdateCounts.fromJson(Map<String, dynamic> json) =>
//       WorkFrontUpdateCounts(
//         projectId: json["project_id"] ?? "",
//         packageId: json["package_id"] ?? "",
//         pboqId: json["pboq_id"] ?? "",
//         totalMs: json["TotalMs"] ?? 0,
//         workFrontUpdateStatus:
//             WorkFrontUpdateStatus.fromJson(json["work_front_update_status"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "project_id": projectId,
//         "package_id": packageId,
//         "pboq_id": pboqId,
//         "TotalMs": totalMs,
//         "work_front_update_status": workFrontUpdateStatus.toJson(),
//       };
// }

// class WorkFrontUpdateStatus {
//   dynamic target;
//   dynamic achievedTarget;
//   String targetAmount;
//   String achievedTargetAmount;

//   WorkFrontUpdateStatus({
//     required this.target,
//     required this.achievedTarget,
//     required this.targetAmount,
//     required this.achievedTargetAmount,
//   });

//   factory WorkFrontUpdateStatus.fromJson(Map<String, dynamic> json) =>
//       WorkFrontUpdateStatus(
//         target: json["target"] ?? "",
//         achievedTarget: json["achieved_target"] ?? "",
//         targetAmount: json["target_amount"] ?? "",
//         achievedTargetAmount: json["achieved_target_amount"] ?? "",
//       );

//   Map<String, dynamic> toJson() => {
//         "target": target,
//         "achieved_target": achievedTarget,
//         "target_amount": targetAmount,
//         "achieved_target_amount": achievedTargetAmount,
//       };
// }

class WorkFrontUpdateItem {
  Map<String, dynamic> fields;

  WorkFrontUpdateItem({required this.fields});

  factory WorkFrontUpdateItem.fromJson(Map<String, dynamic> json) =>
      WorkFrontUpdateItem(fields: json);

  Map<String, dynamic> toJson() => fields;

  String getField(String fieldName) {
    return fields[fieldName]?.toString() ?? '';
  }
}
