// To parse this JSON data, do
//
//     final getDeleteMeasurmentResponse = getDeleteMeasurmentResponseFromJson(jsonString);

import 'dart:convert';

List<GetDeleteMeasurmentResponse> getDeleteMeasurmentResponseFromJson(String str) => List<GetDeleteMeasurmentResponse>.from(json.decode(str).map((x) => GetDeleteMeasurmentResponse.fromJson(x)));

String getDeleteMeasurmentResponseToJson(List<GetDeleteMeasurmentResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDeleteMeasurmentResponse {
    bool status;
    String error;
    String message;
    dynamic data;

    GetDeleteMeasurmentResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetDeleteMeasurmentResponse.fromJson(Map<String, dynamic> json) => GetDeleteMeasurmentResponse(
        status: json["status"]??"",
        error: json["error"]??"",
        message: json["message"]??"",
        data: json["data"]??[],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "message": message,
        "data": data,
    };
}
