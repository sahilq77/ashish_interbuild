import 'dart:convert';

// JSON → Object
GetWorkfontupdateListResponse getWorkfontupdateListResponseFromJson(String str) =>
    GetWorkfontupdateListResponse.fromJson(json.decode(str));

// Object → JSON
String getWorkfontupdateListResponseToJson(GetWorkfontupdateListResponse data) =>
    json.encode(data.toJson());

class GetWorkfontupdateListResponse {
  bool status;
  dynamic error;
  String message;
  WorkfontupdateData data;

  GetWorkfontupdateListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetWorkfontupdateListResponse.fromJson(Map<String, dynamic> json) =>
      GetWorkfontupdateListResponse(
        status: json["status"] as bool,
        error: json["error"],
        message: json["message"] as String,
        data: WorkfontupdateData.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": data.toJson(),
      };
}

class WorkfontupdateData {
  int draw;
  int recordsTotal;
  int recordsFiltered;
  AppColumnDetails appColumnDetails;
  List<WorkfontupdateItem> data;

  WorkfontupdateData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
  });

  factory WorkfontupdateData.fromJson(Map<String, dynamic> json) => WorkfontupdateData(
        draw: json["draw"] ?? 0,
        recordsTotal: json["recordsTotal"] ?? 0,
        recordsFiltered: json["recordsFiltered"] ?? 0,
        appColumnDetails:
            AppColumnDetails.fromJson(json["app_column_details"] as Map<String, dynamic>),
        data: (json["data"] as List)
            .map((x) => WorkfontupdateItem.fromJson(x as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "draw": draw,
        "recordsTotal": recordsTotal,
        "recordsFiltered": recordsFiltered,
        "app_column_details": appColumnDetails.toJson(),
        "data": data.map((x) => x.toJson()).toList(),
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
        columns: List<String>.from(json["columns"] ?? []),
        frontDisplayColumns: List<String>.from(json["front_display_columns"] ?? []),
        frontSecondaryDisplayColumns:
            List<String>.from(json["front_secondary_display_columns"] ?? []),
        buttonDisplayColumn: List<String>.from(json["button_display_column"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "columns": columns,
        "front_display_columns": frontDisplayColumns,
        "front_secondary_display_columns": frontSecondaryDisplayColumns,
        "button_display_column": buttonDisplayColumn,
      };
}

class WorkfontupdateItem {
  Map<String, dynamic> fields;

  WorkfontupdateItem({required this.fields});

  factory WorkfontupdateItem.fromJson(Map<String, dynamic> json) =>
      WorkfontupdateItem(fields: json);

  Map<String, dynamic> toJson() => fields;

  String getField(String fieldName) {
    return fields[fieldName]?.toString() ?? '';
  }
}