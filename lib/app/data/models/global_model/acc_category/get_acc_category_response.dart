// To parse this JSON data, do
//
//     final getAccCategoryResponse = getAccCategoryResponseFromJson(jsonString);

import 'dart:convert';

List<GetAccCategoryResponse> getAccCategoryResponseFromJson(String str) =>
    List<GetAccCategoryResponse>.from(
      json.decode(str).map((x) => GetAccCategoryResponse.fromJson(x)),
    );

String getAccCategoryResponseToJson(List<GetAccCategoryResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAccCategoryResponse {
  bool status;
  dynamic error;
  String message;
  List<AccCategoryData> data;

  GetAccCategoryResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetAccCategoryResponse.fromJson(Map<String, dynamic> json) =>
      GetAccCategoryResponse(
        status: json["status"],
        error: json["error"],
        message: json["message"],
        data: List<AccCategoryData>.from(json["data"].map((x) => AccCategoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class AccCategoryData {
  String accCategoryId;
  String accCategoryName;

  AccCategoryData({required this.accCategoryId, required this.accCategoryName});

  factory AccCategoryData.fromJson(Map<String, dynamic> json) => AccCategoryData(
    accCategoryId: json["acc_category_id"] ?? "",
    accCategoryName: json["acc_category_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "acc_category_id": accCategoryId,
    "acc_category_name": accCategoryName,
  };
}
