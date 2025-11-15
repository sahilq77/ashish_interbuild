// To parse this JSON data, do
//
//     final getEditPboqMeasurmentResponse = getEditPboqMeasurmentResponseFromJson(jsonString);

import 'dart:convert';

List<GetEditPboqMeasurmentResponse> getEditPboqMeasurmentResponseFromJson(String str) => List<GetEditPboqMeasurmentResponse>.from(json.decode(str).map((x) => GetEditPboqMeasurmentResponse.fromJson(x)));

String getEditPboqMeasurmentResponseToJson(List<GetEditPboqMeasurmentResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetEditPboqMeasurmentResponse {
    bool status;
    String error;
    String message;
    dynamic data;

    GetEditPboqMeasurmentResponse({
        required this.status,
        required this.error,
        required this.message,
        required this.data,
    });

    factory GetEditPboqMeasurmentResponse.fromJson(Map<String, dynamic> json) => GetEditPboqMeasurmentResponse(
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
