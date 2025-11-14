// To parse this JSON data, do
//
//     final getPboqListResponse = getPboqListResponseFromJson(jsonString);

import 'dart:convert';

List<GetPboqMeasurementSheetResponse> getPboqMeasurementsheetResponseFromJson(
  String str,
) => List<GetPboqMeasurementSheetResponse>.from(
  json.decode(str).map((x) => GetPboqMeasurementSheetResponse.fromJson(x)),
);

String getPboqMeasurementsheetResponseToJson(
  List<GetPboqMeasurementSheetResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPboqMeasurementSheetResponse {
  bool status;
  dynamic error;
  String message;
  Data data;

  GetPboqMeasurementSheetResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetPboqMeasurementSheetResponse.fromJson(Map<String, dynamic> json) =>
      GetPboqMeasurementSheetResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int draw;
  int recordsTotal;
  int recordsFiltered;
  AppColumnDetails appColumnDetails;
  List<AllData> data;

  Data({
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.appColumnDetails,
    required this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    draw: json["draw"] ?? 0,
    recordsTotal: json["recordsTotal"] ?? 0,
    recordsFiltered: json["recordsFiltered"] ?? 0,
    appColumnDetails: AppColumnDetails.fromJson(json["app_column_details"] ?? {}),
    data: json["data"] != null ? List<AllData>.from(json["data"].map((x) => AllData.fromJson(x))) : [],
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

  factory AppColumnDetails.fromJson(Map<String, dynamic> json) =>
      AppColumnDetails(
        columns: List<String>.from(json["columns"]?.map((x) => x) ?? []),
        frontDisplayColumns: List<String>.from(
          json["front_display_columns"]?.map((x) => x) ?? [],
        ),
        frontSecondaryDisplayColumns: List<String>.from(
          json["front_secondary_display_columns"]?.map((x) => x) ?? [],
        ),
        buttonDisplayColumn: List<String>.from(
          json["button_display_column"]?.map((x) => x) ?? [],
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

class AllData {
  Map<String, dynamic> fields;

  AllData({required this.fields});

  factory AllData.fromJson(Map<String, dynamic> json) =>
      AllData(fields: Map<String, dynamic>.from(json));

  Map<String, dynamic> toJson() => fields;

  // Helper methods to get common fields
  String get pboqId => fields["pboq_id"]?.toString() ?? "";
  String get systemId => fields["System ID"]?.toString() ?? "";
  String get pboqName => fields["PBOQ Name"]?.toString() ?? "";
  String get cboqNo => fields["CBOQ No"]?.toString() ?? "";
  String get packageName => fields["Package Name"]?.toString() ?? "";
  String get uom => fields["UOM"]?.toString() ?? "";
  String get zones => fields["Zones"]?.toString() ?? "";
  String get pboqQty => fields["PBOQ Qty"]?.toString() ?? "";
  int get msQty => int.tryParse(fields["MS Qty"]?.toString() ?? "0") ?? 0;

  // Dynamic field getter
  String getField(String key) => fields[key]?.toString() ?? "";
}
