import 'dart:convert';

// JSON → Object
GetAccListResponse getAccListResponseFromJson(String str) =>
    GetAccListResponse.fromJson(json.decode(str));

// Object → JSON
String getAccListResponseToJson(GetAccListResponse data) =>
    json.encode(data.toJson());

class GetAccListResponse {
  final bool status;
  final dynamic error;
  final String message;
  final AccData data;

  GetAccListResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetAccListResponse.fromJson(Map<String, dynamic> json) =>
      GetAccListResponse(
        status: json["status"] as bool,
        error: json["error"],
        message: json["message"] as String,
        data: AccData.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": data.toJson(),
      };
}

class AccData {
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final AppColumnDetails appColumnDetails;
  final List<AccItem> data;

  AccData({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
  });

  factory AccData.fromJson(Map<String, dynamic> json) => AccData(
        draw: json["draw"] ?? 0,
        recordsTotal: json["recordsTotal"] ?? 0,
        recordsFiltered: json["recordsFiltered"] ?? 0,
        appColumnDetails: AppColumnDetails.fromJson(
            json["app_column_details"] as Map<String, dynamic>),
        data: (json["data"] as List)
            .map((e) => AccItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "draw": draw,
        "recordsTotal": recordsTotal,
        "recordsFiltered": recordsFiltered,
        "app_column_details": appColumnDetails.toJson(),
        "data": data.map((e) => e.toJson()).toList(),
      };
}

class AppColumnDetails {
  final List<String> columns;
  final List<String> frontDisplayColumns;
  final List<String> frontSecondaryDisplayColumns;
  final List<String> buttonDisplayColumn;

  AppColumnDetails({
    required this.columns,
    required this.frontDisplayColumns,
    required this.frontSecondaryDisplayColumns,
    required this.buttonDisplayColumn,
  });

  factory AppColumnDetails.fromJson(Map<String, dynamic> json) =>
      AppColumnDetails(
        columns: List<String>.from(json["columns"] ?? []),
        frontDisplayColumns:
            List<String>.from(json["front_display_columns"] ?? []),
        frontSecondaryDisplayColumns:
            List<String>.from(json["front_secondary_display_columns"] ?? []),
        buttonDisplayColumn:
            List<String>.from(json["button_display_column"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "columns": columns,
        "front_display_columns": frontDisplayColumns,
        "front_secondary_display_columns": frontSecondaryDisplayColumns,
        "button_display_column": buttonDisplayColumn,
      };
}

class AccItem {
  final Map<String, dynamic> fields;

  AccItem({required this.fields});

  factory AccItem.fromJson(Map<String, dynamic> json) =>
      AccItem(fields: json);

  Map<String, dynamic> toJson() => fields;

  // Helper to safely get field value as String
  String getField(String fieldName) {
    return fields[fieldName]?.toString() ?? '';
  }

  // Optional: Add typed getters if you know certain fields
  // String get name => getField('name');
  // int get id => int.tryParse(getField('id')) ?? 0;
}