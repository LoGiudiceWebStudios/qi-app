import 'dart:convert';

class OtpVeificationResponseModel {
    bool? status;
    String? message;
    int? code;

    OtpVeificationResponseModel({
        this.status,
        this.message,
        this.code,
    });

    OtpVeificationResponseModel copyWith({
        bool? status,
        String? message,
        int? code,
    }) => 
        OtpVeificationResponseModel(
            status: status ?? this.status,
            message: message ?? this.message,
            code: code ?? this.code,
        );

    factory OtpVeificationResponseModel.fromRawJson(String str) => OtpVeificationResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory OtpVeificationResponseModel.fromJson(Map<String, dynamic> json) => OtpVeificationResponseModel(
        status: json["status"],
        message: json["message"],
        code: json["code"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "code": code,
    };
}
