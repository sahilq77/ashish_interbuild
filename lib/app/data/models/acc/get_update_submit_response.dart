// To parse this JSON data, do
//
//     final getUpdateSubmitResponse = getUpdateSubmitResponseFromJson(jsonString);

import 'dart:convert';

List<GetUpdateSubmitResponse> getUpdateSubmitResponseFromJson(String str) => List<GetUpdateSubmitResponse>.from(json.decode(str).map((x) => GetUpdateSubmitResponse.fromJson(x)));

String getUpdateSubmitResponseToJson(List<GetUpdateSubmitResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetUpdateSubmitResponse {
    bool status;
    dynamic error;
    String message;

    GetUpdateSubmitResponse({
        required this.status,
        required this.error,
        required this.message,
    });

    factory GetUpdateSubmitResponse.fromJson(Map<String, dynamic> json) => GetUpdateSubmitResponse(
        status: json["status"]??"",
        error: json["error"]??"",
        message: json["message"]??"",
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
    };
}
