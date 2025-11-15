// To parse this JSON data, do
//
//     final getAddDeductionResponse = getAddDeductionResponseFromJson(jsonString);

import 'dart:convert';

List<GetAddDeductionResponse> getAddDeductionResponseFromJson(String str) =>
    List<GetAddDeductionResponse>.from(
      json.decode(str).map((x) => GetAddDeductionResponse.fromJson(x)),
    );

String getAddDeductionResponseToJson(List<GetAddDeductionResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAddDeductionResponse {
  bool status;
  String error;
  String message;
  Data data;

  GetAddDeductionResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetAddDeductionResponse.fromJson(Map<String, dynamic> json) =>
      GetAddDeductionResponse(
        status: json["status"] ?? "",
        error: json["error"] ?? "",
        message: json["message"] ?? "",
        data: Data.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic> json) => Data();

  Map<String, dynamic> toJson() => {};
}
