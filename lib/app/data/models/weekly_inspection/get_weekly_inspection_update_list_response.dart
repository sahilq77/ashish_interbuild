import 'dart:convert';

GetUpdateWeeklyInspectionListResponse
getUpdateWeeklyInspectionListResponseFromJson(String str) =>
    GetUpdateWeeklyInspectionListResponse.fromJson(json.decode(str));

String getUpdateWeeklyInspectionListResponseToJson(
  GetUpdateWeeklyInspectionListResponse data,
) => json.encode(data.toJson());

class GetUpdateWeeklyInspectionListResponse {
  bool status;
  dynamic error;
  String message;
  WIRData data;

  GetUpdateWeeklyInspectionListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetUpdateWeeklyInspectionListResponse.fromJson(
    Map<String, dynamic> json,
  ) => GetUpdateWeeklyInspectionListResponse(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: WIRData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class WIRData {
  int draw;
  int recordsTotal;
  int recordsFiltered;
  AppColumnDetails appColumnDetails;
  List<WIRItem> data;
  // WIRCounts? dprCounts;

  WIRData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
    // this.dprCounts,
  });

  factory WIRData.fromJson(Map<String, dynamic> json) => WIRData(
    draw: json["draw"] ?? 0,
    recordsTotal: json["recordsTotal"] ?? 0,
    recordsFiltered: json["recordsFiltered"] ?? 0,
    appColumnDetails: AppColumnDetails.fromJson(json["app_column_details"]),
    data: List<WIRItem>.from(json["data"].map((x) => WIRItem.fromJson(x))),
    // dprCounts: json["wir_counts"] != null
    //     ? WIRCounts.fromJson(json["wir_counts"])
    //     : null,
  );

  Map<String, dynamic> toJson() => {
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "app_column_details": appColumnDetails.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    // if (dprCounts != null) "wir_counts": dprCounts!.toJson(),
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

// class WIRCounts {
//   String projectId;
//   String packageId;
//   String pboqId;
//   int totalMs;
//   InspectionStatus wirStatus;

//   WIRCounts({
//     required this.projectId,
//     required this.packageId,
//     required this.pboqId,
//     required this.totalMs,
//     required this.wirStatus,
//   });

//   factory WIRCounts.fromJson(Map<String, dynamic> json) => WIRCounts(
//     projectId: json["project_id"] ?? "",
//     packageId: json["package_id"] ?? "",
//     pboqId: json["pboq_id"] ?? "",
//     totalMs: json["TotalMs"] ?? 0,
//     wirStatus: InspectionStatus.fromJson(json["inspection_status"]),
//   );

//   Map<String, dynamic> toJson() => {
//     "project_id": projectId,
//     "package_id": packageId,
//     "pboq_id": pboqId,
//     "TotalMs": totalMs,
//     "inspection_status": wirStatus.toJson(),
//   };
// }

// class InspectionStatus {
//   int target;
//   int achievedTarget;
//   String targetAmount;
//   String achievedTargetAmount;

//   InspectionStatus({
//     required this.target,
//     required this.achievedTarget,
//     required this.targetAmount,
//     required this.achievedTargetAmount,
//   });

//   factory InspectionStatus.fromJson(Map<String, dynamic> json) =>
//       InspectionStatus(
//         target: json["target"] ?? 0,
//         achievedTarget: json["achieved_target"] ?? 0,
//         targetAmount: json["target_amount"] ?? "0.00",
//         achievedTargetAmount: json["achieved_target_amount"] ?? "0.00",
//       );

//   Map<String, dynamic> toJson() => {
//     "target": target,
//     "achieved_target": achievedTarget,
//     "target_amount": targetAmount,
//     "achieved_target_amount": achievedTargetAmount,
//   };
// }

class WIRItem {
  Map<String, dynamic> fields;

  WIRItem({required this.fields});

  factory WIRItem.fromJson(Map<String, dynamic> json) => WIRItem(fields: json);

  Map<String, dynamic> toJson() => fields;

  String getField(String fieldName) {
    return fields[fieldName]?.toString() ?? '';
  }
}
