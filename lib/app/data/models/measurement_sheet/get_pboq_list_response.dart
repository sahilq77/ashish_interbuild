// To parse this JSON data, do
//
//     final getPboqListResponse = getPboqListResponseFromJson(jsonString);

import 'dart:convert';

List<GetPboqListResponse> getPboqListResponseFromJson(String str) => List<GetPboqListResponse>.from(json.decode(str).map((x) => GetPboqListResponse.fromJson(x)));

String getPboqListResponseToJson(List<GetPboqListResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPboqListResponse {
    bool status;
    dynamic error;
    String message;
    Data data;

    GetPboqListResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetPboqListResponse.fromJson(Map<String, dynamic> json) => GetPboqListResponse(
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
        draw: json["draw"],
        recordsTotal: json["recordsTotal"],
        recordsFiltered: json["recordsFiltered"],
        appColumnDetails: AppColumnDetails.fromJson(json["app_column_details"]),
        data: List<AllData>.from(json["data"].map((x) => AllData.fromJson(x))),
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
    List<String> buttonDisplayColumn;

    AppColumnDetails({
        required this.columns,
        required this.frontDisplayColumns,
        required this.buttonDisplayColumn,
    });

    factory AppColumnDetails.fromJson(Map<String, dynamic> json) => AppColumnDetails(
        columns: List<String>.from(json["columns"].map((x) => x)),
        frontDisplayColumns: List<String>.from(json["front_display_columns"].map((x) => x)),
        buttonDisplayColumn: List<String>.from(json["button_display_column"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "columns": List<dynamic>.from(columns.map((x) => x)),
        "front_display_columns": List<dynamic>.from(frontDisplayColumns.map((x) => x)),
        "button_display_column": List<dynamic>.from(buttonDisplayColumn.map((x) => x)),
    };
}

class AllData {
    String pboqId;
    String length;
    String breadth;
    String height;
    int srNo;
    String systemId;
    String pboqName;
    String cboqNo;
    String packageName;
    String uom;
    String zones;
    String pboqQty;
    int msQty;
    String field1;
    String field2;
    String field3;
    String field4;
    String viewDeductions;
    String viewDetails;

    AllData({
        required this.pboqId,
        required this.length,
        required this.breadth,
        required this.height,
        required this.srNo,
        required this.systemId,
        required this.pboqName,
        required this.cboqNo,
        required this.packageName,
        required this.uom,
        required this.zones,
        required this.pboqQty,
        required this.msQty,
        required this.field1,
        required this.field2,
        required this.field3,
        required this.field4,
        required this.viewDeductions,
        required this.viewDetails,
    });

    factory AllData.fromJson(Map<String, dynamic> json) => AllData(
        pboqId: json["pboq_id"]??"",
        length: json["length"]??"",
        breadth: json["breadth"]??"",
        height: json["height"]??"",
        srNo: json["Sr No"]??"",
        systemId: json["System ID"]??"",
        pboqName: json["PBOQ Name"]??"",
        cboqNo: json["CBOQ No"]??"",
        packageName: json["Package Name"]??"",
        uom: json["UOM"]??"",
        zones: json["Zones"]??"",
        pboqQty: json["PBOQ Qty"]??"",
        msQty: json["MS Qty"]??"",
        field1: json["Field 1"]??"",
        field2: json["Field 2"]??"",
        field3: json["Field 3"]??"",
        field4: json["Field 4"]??"",
        viewDeductions: json["View Deductions"]??"",
        viewDetails: json["View Details"]??"",
    );

    Map<String, dynamic> toJson() => {
        "pboq_id": pboqId,
        "length": length,
        "breadth": breadth,
        "height": height,
        "Sr No": srNo,
        "System ID": systemId,
        "PBOQ Name": pboqName,
        "CBOQ No": cboqNo,
        "Package Name": packageName,
        "UOM": uom,
        "Zones": zones,
        "PBOQ Qty": pboqQty,
        "MS Qty": msQty,
        "Field 1": field1,
        "Field 2": field2,
        "Field 3": field3,
        "Field 4": field4,
        "View Deductions": viewDeductions,
        "View Details": viewDetails,
    };
}
