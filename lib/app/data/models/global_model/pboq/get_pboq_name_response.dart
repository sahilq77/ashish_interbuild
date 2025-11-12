// To parse this JSON data, do
//
//     final getPboqNameResponse = getPboqNameResponseFromJson(jsonString);

import 'dart:convert';

List<GetPboqNameResponse> getPboqNameResponseFromJson(String str) =>
    List<GetPboqNameResponse>.from(
      json.decode(str).map((x) => GetPboqNameResponse.fromJson(x)),
    );

String getPboqNameResponseToJson(List<GetPboqNameResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPboqNameResponse {
  bool status;
  dynamic error;
  String message;
  List<PboqData> data;

  GetPboqNameResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetPboqNameResponse.fromJson(Map<String, dynamic> json) =>
      GetPboqNameResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<PboqData>.from(
          json["data"].map((x) => PboqData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PboqData {
  String pboqId;
  String qty;
  String rate;
  String amount;
  String pboqName;
  String cboqNo;
  String unitName;
  String length;
  String breadth;
  String height;
  String packageName;
  String projectCode;
  String projectName;
  String mappedZoneNames;

  PboqData({
    required this.pboqId,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.pboqName,
    required this.cboqNo,
    required this.unitName,
    required this.length,
    required this.breadth,
    required this.height,
    required this.packageName,
    required this.projectCode,
    required this.projectName,
    required this.mappedZoneNames,
  });

  factory PboqData.fromJson(Map<String, dynamic> json) => PboqData(
    pboqId: json["pboq_id"] ?? "",
    qty: json["qty"] ?? "",
    rate: json["rate"] ?? "",
    amount: json["amount"] ?? "",
    pboqName: json["pboq_name"] ?? "",
    cboqNo: json["cboq_no"] ?? "",
    unitName: json["unit_name"] ?? "",
    length: json["length"] ?? "",
    breadth: json["breadth"] ?? "",
    height: json["height"] ?? "",
    packageName: json["package_name"] ?? "",
    projectCode: json["project_code"] ?? "",
    projectName: json["project_name"] ?? "",
    mappedZoneNames: json["mapped_zone_names"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "pboq_id": pboqId,
    "qty": qty,
    "rate": rate,
    "amount": amount,
    "pboq_name": pboqName,
    "cboq_no": cboqNo,
    "unit_name": unitName,
    "length": length,
    "breadth": breadth,
    "height": height,
    "package_name": packageName,
    "project_code": projectCode,
    "project_name": projectName,
    "mapped_zone_names": mappedZoneNames,
  };
}
