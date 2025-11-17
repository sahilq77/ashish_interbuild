import 'dart:convert';

GetDprListResponse getDprListResponseFromJson(String str) => GetDprListResponse.fromJson(json.decode(str));

String getDprListResponseToJson(GetDprListResponse data) => json.encode(data.toJson());

class GetDprListResponse {
  bool status;
  dynamic error;
  String message;
  DprData data;

  GetDprListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetDprListResponse.fromJson(Map<String, dynamic> json) => GetDprListResponse(
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

  DprData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
  });

  factory DprData.fromJson(Map<String, dynamic> json) => DprData(
    draw: json["draw"] ?? 0,
    recordsTotal: json["recordsTotal"] ?? 0,
    recordsFiltered: json["recordsFiltered"] ?? 0,
    appColumnDetails: AppColumnDetails.fromJson(json["app_column_details"]),
    data: List<DprItem>.from(json["data"].map((x) => DprItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "app_column_details": appColumnDetails.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
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

class DprItem {
  Map<String, dynamic> fields;

  DprItem({required this.fields});

  factory DprItem.fromJson(Map<String, dynamic> json) => DprItem(fields: json);

  Map<String, dynamic> toJson() => fields;

  String getField(String fieldName) {
    return fields[fieldName]?.toString() ?? '';
  }
}