import 'dart:convert';

class ResetResponseModel {
    bool? status;
    String? message;
    int? code;

    ResetResponseModel({
        this.status,
        this.message,
        this.code,
    });

    ResetResponseModel copyWith({
        bool? status,
        String? message,
        int? code,
    }) => 
        ResetResponseModel(
            status: status ?? this.status,
            message: message ?? this.message,
            code: code ?? this.code,
        );

    factory ResetResponseModel.fromRawJson(String str) => ResetResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ResetResponseModel.fromJson(Map<String, dynamic> json) => ResetResponseModel(
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
