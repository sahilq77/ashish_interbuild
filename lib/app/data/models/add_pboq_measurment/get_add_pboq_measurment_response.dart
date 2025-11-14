// To parse this JSON data, do
//
//     final getAddPboqMsResponse = getAddPboqMsResponseFromJson(jsonString);

import 'dart:convert';

List<GetAddPboqMsResponse> getAddPboqMsResponseFromJson(String str) =>
    List<GetAddPboqMsResponse>.from(
      json.decode(str).map((x) => GetAddPboqMsResponse.fromJson(x)),
    );

String getAddPboqMsResponseToJson(List<GetAddPboqMsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAddPboqMsResponse {
  bool status;
  String? error;
  String? message;
  Map<String, dynamic>? data;

  GetAddPboqMsResponse({
    required this.status,
    this.error,
    this.message,
    this.data,
  });

  factory GetAddPboqMsResponse.fromJson(Map<String, dynamic> json) =>
      GetAddPboqMsResponse(
        status: json["status"] ?? false,
        error: json["error"]?.toString(),
        message: json["message"]?.toString(),
        data: json["data"] != null ? Map<String, dynamic>.from(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": data,
  };
}
