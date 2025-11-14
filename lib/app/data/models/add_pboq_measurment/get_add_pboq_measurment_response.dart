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
  String error;
  String message;
  List<dynamic> data;

  GetAddPboqMsResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory GetAddPboqMsResponse.fromJson(Map<String, dynamic> json) =>
      GetAddPboqMsResponse(
        status: json["status"] ?? "",
        error: json["error"] ?? "",
        message: json["message"] ?? "",
        data: List<dynamic>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "error": error,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x)),
  };
}
