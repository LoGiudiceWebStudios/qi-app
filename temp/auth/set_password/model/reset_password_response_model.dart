import 'dart:convert';

class ResetPasswordResponseModel {
    bool? status;
    String? message;
    int? code;

    ResetPasswordResponseModel({
        this.status,
        this.message,
        this.code,
    });

    ResetPasswordResponseModel copyWith({
        bool? status,
        String? message,
        int? code,
    }) => 
        ResetPasswordResponseModel(
            status: status ?? this.status,
            message: message ?? this.message,
            code: code ?? this.code,
        );

    factory ResetPasswordResponseModel.fromRawJson(String str) => ResetPasswordResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) => ResetPasswordResponseModel(
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
